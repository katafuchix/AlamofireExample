//
//  HttpClientRx.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/10.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

enum NetworkError: Error {
    case invalidStatusCode(Int)
}

struct HttpClientRx {
    
    // get 単体
    static func sendGETRequestRxAlamofire(url: String, parameters: [String: Any]?) -> Observable<Data> {
        return RxAlamofire.request(.get, url, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseData()
            .map { response, data in
                return data
            }
    }
    // Do any additional setup after loading the view.
    /*
    HttpClientRx.sendGETRequestRxAlamofire(url: "https://example.com/api/data", parameters: ["key": "value"])
        .subscribe(onNext: { data in
            // 受信したデータを処理する
            print("Received data: \(data)")
        }, onError: { error in
            print("Error: \(error.localizedDescription)")
        })
        .disposed(by: rx.disposeBag)
    
    self.viewModel.searchWord.accept("Blue")
    self.viewModel.searchTrigger.onNext(())
    */

    
    // Decodable利用
    static func fetchData<T: Decodable>(url: String, responseType: T.Type) -> Observable<T> {
        return RxAlamofire.requestData(.get, url)
            .flatMap { response, data -> Observable<Data> in
                let statusCode = response.statusCode
                if 200..<300 ~= statusCode {
                    return Observable.just(data)
                } else {
                    return Observable.error(NetworkError.invalidStatusCode(statusCode))
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { error in
                if let afError = error as? AFError, case .responseValidationFailed(let reason) = afError, case .unacceptableStatusCode(let code) = reason {
                    return Observable.error(NetworkError.invalidStatusCode(code))
                }
                return Observable.error(error)
            }
    }

    // エラー詳細
    func fetchData<T: Decodable>(method: HTTPMethod,
                                 url: String,
                                 parameters: [String: Any]?,
                                 headers: HTTPHeaders?,
                                 responseType: T.Type) -> Observable<T> {
        
        return RxAlamofire.requestData(method, url, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<Data> in
                let statusCode = response.statusCode
                if 200..<300 ~= statusCode {
                    return Observable.just(data)
                } else {
                    return Observable.error(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { error in
                if let afError = error as? AFError, case .responseValidationFailed(let reason) = afError, case .unacceptableStatusCode(let code) = reason {
                    return Observable.error(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: code)))
                }
                return Observable.error(error)
            }
    }

    /*
     // 使用例
     struct MyData: Codable {
         let userId: Int
         let id: Int
         let title: String
         let completed: Bool
     }

     let disposeBag = DisposeBag()
     let url = "https://jsonplaceholder.typicode.com/todos/1"
     fetchData(method: .get, url: url, parameters: nil, headers: nil, responseType: MyData.self)
         .subscribe(onNext: { myData in
             print("Received data: \(myData)")
         }, onError: { error in
             print("Error: \(error)")
         })
         .disposed(by: disposeBag)
     */
    
    
    // Session 考慮
    private static let manager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // リクエストのタイムアウト時間を10秒に設定
        configuration.urlCache = URLCache.shared
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return Session(configuration: configuration)
    }()
    
    /*
    汎用メソッド
     ・エンドポイントURL
     ・HTTPリクエストメソッド
     ・リクエストパラメーター
     ・ヘッダー
     ・レスポンスのJSONをデコードするための型
    */
    static func sendRequest<T: Codable>(url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default) -> Observable<T> {
        // URLEncoding.default JSONEncoding.default
        
        let request = manager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        return request.rx.responseData()
            .debug()    // 詳細ログ
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
    
}
