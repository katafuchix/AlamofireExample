# AlamofireExample

- Alamofire (5.6.4)
- RxAlamofire (6.1.1)


```
  private static let manager: Session = {
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 10 
      configuration.urlCache = URLCache.shared
      configuration.requestCachePolicy = .useProtocolCachePolicy
      return Session(configuration: configuration)
  }()

  static func sendRequest<T: Codable>(url: String, 
                                      method: HTTPMethod, 
                                      parameters: Parameters?, 
                                      headers: HTTPHeaders? = nil, 
                                      encoding: ParameterEncoding = JSONEncoding.default) -> Observable<T> {

      let request = manager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)

      return request.rx.responseData()
          .debug() 
          .flatMap { response, data -> Observable<T> in
              guard (200..<300).contains(response.statusCode) else {
                  let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                  return Observable.error(error)
              }
              let decoder = JSONDecoder()
              do {
                  let response = try decoder.decode(T.self, from: data)
                  return Observable.just(response)
              } catch {
                  return Observable.error(error)
              }
          }
  }
```
