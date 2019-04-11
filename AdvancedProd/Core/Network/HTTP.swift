//
//  HTTP.swift
//  NetworkLayerTest
//
//  Created by Gino on 05.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

import PromiseKit

final public class HTTP {
  
  enum Method: String {
    /// The GET method requests a representation of the specified resource.
    /// Requests using GET should only retrieve data.
    case GET
    
    /// The POST method is used to submit an entity to the specified
    /// resource, often causing a change in state or side effects on the server.
    case POST
    
    /// The PUT method replaces all current representations of the target
    /// resource with the request payload.
    case PUT
    
    /// The DELETE method deletes the specified resource.
    case DELETE
  }
  
  /// The ParameterEncoding defines the method for encoding the parameters when
  /// creating the URLRequest.
  public enum ParameterEncoding {
    
    /// Parameters encoded as JSON.
    case JSON
    
    /// Parameters encoded in the URL.
    case queryString
    
    /// Parameters are send within the body as form data.
    case httpBody
  }
  
  typealias QueryParameters = [String: String]
  
  /// A dictionary of headers to apply to a `URLRequest`.
  typealias Headers = [String: String]
  
  /// The default header to use for all requests
  static var defaultHeaders: Headers {
    return [
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Accept-Language": "en",
      "Content-Language": "en"
    ]
  }

  
  
  /// The Request struct holds all different options for the request.
  struct RequestOptions {
    /// The URL of the request.
    let urlComponents: URLComponents
    
    let path: String
    
    /// The headers to be sent with the request.
    let headers: HTTP.Headers
    
    /// The optional parameters to be sent with the request.
    let parameters: HTTP.QueryParameters?
    
    /// The parameter encoding to be used.
    let encoding: HTTP.ParameterEncoding
    
    /// The method of the request.
    let method: HTTP.Method
  }
  
  // MARK: - Response
  
  /**
   The a `HTTP.Response` struct is returned for every request. It holds
   the original `HTTPURLResponse` object and the data received. It also
   comes with conveniece methods for accessing JSON and plain text responses.
   
   ````
   http.get("https://bikemap.net") { response, error in
   if response.success == true {
   let json = response.json
   log.verbose(json)
   }
   }
   ````
   
   See `HTTPURLResponse` extension and `HTTPURLResponseStatus` for more.
   */
  struct Response {
    
    /// The original `HTTPURLResponse` received.
    public let urlResponse: HTTPURLResponse
    
    /// The data received from the server.
    public let data: Data?
    
    /// Convenience access to the `HTTPURLResponseStatus` of the
    /// `HTTPURLResponse`.
    public var status: HTTPURLResponseStatus {
      return self.urlResponse.status
    }
    
    /// The attribute is available if the data received from the server can be
    /// decoded as json.
    /// The type may be either `[Any]` or `[AnyHashable: Any]`, cast at will.
    public var json: Any? {
      
      guard let data = self.data else {
        return nil
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data)
        return json
      } catch {
        print("Cannot decode body as JSON")
        return nil
      }
    }
    
    /// The body attribute is available if the data received from the server
    /// can be decoded as UTF8 text.
    var body: String? {
      guard let data = self.data else {
        return nil
      }
      return String(data: data, encoding: String.Encoding.utf8)
    }
    
    /// Initiates and returns a new struct.
    ///
    /// - Parameters:
    ///   - urlResponse: The original HTTPURLResponse.
    ///   - data: The data received from the server.
    init(_ urlResponse: HTTPURLResponse, data: Data?) {
      self.urlResponse = urlResponse
      self.data = data
    }
  }
  
  /// A response handler type for the API responses.
  typealias ResponseHandler = (HTTP.Response?, Error?) -> Void
  
  @discardableResult
  func get(_ urlComponents: URLComponents,
           path: String,
           headers: HTTP.Headers = HTTP.defaultHeaders,
           parameters: HTTP.QueryParameters? = nil) -> Promise<HTTP.Response> {
    
    let options = RequestOptions(
      urlComponents: urlComponents,
      path: path,
      headers: headers,
      parameters: parameters,
      encoding: .queryString,
      method: .GET)
    
    return self.request(options)
  }
  
  @discardableResult
  func request(_ options: RequestOptions) -> Promise<HTTP.Response> {
    
    var urlComponents = options.urlComponents
    
    if let parameters = options.parameters, options.encoding == .queryString {
      urlComponents.path = options.path
      urlComponents.setQueryItems(with: parameters)
    }
    
    guard let requestURL = urlComponents.url else {
      return Promise { $0.reject(APIError.invalidURL) }
    }
    
    // Creating the URLRequest with the url, the method.
    // Also adding the custom HTTP headers.
    var urlRequest: URLRequest = URLRequest(url: requestURL)
    urlRequest.httpMethod = options.method.rawValue
    
    options.headers.forEach {
      urlRequest.addValue($1, forHTTPHeaderField: $0)
    }
    if urlRequest.value(forHTTPHeaderField: "User-Agent") == nil {
      urlRequest.addValue(
        UIDevice.current.userAgent,
        forHTTPHeaderField: "User-Agent")
    }
    
    // If parameters exist
    if let parameters = options.parameters {
      do {
        if options.encoding == .JSON {
          let json = try JSONSerialization.data(withJSONObject: parameters)
          urlRequest.httpBody = json
        } else if options.encoding == .httpBody {
          let params = parameters
            .map { arg in
              let (key, value) = arg
              return "\(key)=\(HTTP.percentEscapeString("\(value)"))"
            }
            .joined(separator: "&")
          urlRequest.httpBody = params.data(using: String.Encoding.utf8)
        }
      } catch {
        return Promise { $0.reject(APIError.serializationError) }
      }
    }
    
    return self.performDataTask(with: urlRequest)
  }
  
  private func performDataTask(with urlRequest: URLRequest) -> Promise<HTTP.Response> {
    // Creating a HTTP session and a data task on a background queue
    let session: URLSession = URLSession(configuration: .default)
    let queue: DispatchQueue = DispatchQueue(
      label: "test.NetworkLayerTest.networking",
      qos: .utility,
      attributes: .concurrent)
    
    // Wrapping the operation into a Promise
    let promise: Promise<HTTP.Response> = session
      .dataTask(.promise, with: urlRequest)
      .compactMap(on: queue) { data, response -> HTTP.Response in
        // There always has to be a response
        guard let response = response as? HTTPURLResponse else {
          throw APIError.invalidResponse
        }
        
        let responseUrl: String = response.url?.absoluteString ?? "missing url"
        let httpResponse = Response(response, data: data)
        
        // Guarding for a successful response.
        // If the request fails, the appropriate error is thrown.
        guard response.success else {
          var error: APIError = .invalidResponse
          
          if response.status == .unauthorized {
            error = .unauthorized
          } else if response.status == .forbidden {
            error = .forbidden
          } else if response.status == .badRequest {
            if let errorResponse = httpResponse.json as? [AnyHashable: Any] {
              // handle other cases here
            }
          }
          throw error
        }
        
        return httpResponse
    }
    
    return promise
  }
}

extension HTTP {
  
  static func percentEscapeString(_ string: String) -> String {
    var characterSet = CharacterSet.alphanumerics
    characterSet.insert(charactersIn: "-._* ")
    
    return string
      .addingPercentEncoding(withAllowedCharacters: characterSet)!
      .replacingOccurrences(of: " ", with: "+")
      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
  }
}
