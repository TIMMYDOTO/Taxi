//
//  NetworkManager.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 02.08.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

typealias JSON = [String: Any]

class NetworkManager {
    
    // MARK: - Свойства
    
    static let domain: String = "domain.network.manager"
    static let configuration: URLSessionConfiguration = URLSessionConfiguration.default
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    // MARK: - Параметры
    
    let sessionManager = Alamofire.SessionManager(configuration: configuration,
                                                  serverTrustPolicyManager: nil)
    
    
    func performRequest(_ request: CommonRequest, validStatusCodes: [Int] = (200...299).map({$0}), requestHandler: ((DataRequest) -> ())? = nil) -> Promise<Data?> {
        return Promise<Data?> { [unowned self] resolver in
            UIApplication.shared.delegate?.incrementActivityCounter()
            let request = self.sessionManager.request(request.url,
                                                      method: request.method,
                                                      parameters: request.parameters,
                                                      encoding: request.encoding,
                                                      headers: request.headers)
                .responseData(completionHandler: { (response) in
                    UIApplication.shared.delegate?.decrementActivityCounter()
                    if validStatusCodes.contains(response.response?.statusCode ?? 0) {
                        resolver.fulfill(response.result.value)
                    } else {
                        resolver.reject(NetworkManager.parseError(error: response.error ?? RCError.unknown, response: response))
                    }
                })
            requestHandler?(request)
        }
    }
    
    func performRequestJSON(_ request: CommonRequest, validStatusCodes: [Int] = (200...299).map({$0}), requestHandler: ((DataRequest) -> ())? = nil) -> Promise<Any?> {
        return Promise<Any?> { [unowned self] resolver in
            UIApplication.shared.delegate?.incrementActivityCounter()
            let request = self.sessionManager.request(request.url,
                                                      method: request.method,
                                                      parameters: request.parameters,
                                                      encoding: request.encoding,
                                                      headers: request.headers)
                .responseJSON(completionHandler: { (response) in
                    UIApplication.shared.delegate?.decrementActivityCounter()
                    if validStatusCodes.contains(response.response?.statusCode ?? 0) {
                        resolver.fulfill(response.result.value)
                    } else {
                        resolver.reject(NetworkManager.parseError(error: response.error ?? RCError.unknown, response: response))
                    }
                })
            requestHandler?(request)
        }
    }
    
    func performRequestString(_ request: CommonRequest) -> Promise<String?> {
        return Promise<String?> { [unowned self] resolver in
            UIApplication.shared.delegate?.incrementActivityCounter()
            self.sessionManager.request(request.url,
                                        method: request.method,
                                        parameters: request.parameters,
                                        encoding: request.encoding,
                                        headers: request.headers)
                .validate().responseString(completionHandler: { (response) in
                    UIApplication.shared.delegate?.decrementActivityCounter()
                    switch (response.result) {
                    case .success(let result):
                        resolver.fulfill(result)
                        break
                    case .failure(let error):
                        resolver.reject(NetworkManager.parseError(error: error, response: response))
                    }
                })
        }
    }
    
    func performMultipartRequest(_ request: MultipartRequest,
                                 progressHandler: ((_ fractionCompleted: Double) -> ())? = nil) -> Promise<Any?> {
        return Promise<Any?> { [unowned self] resolver in
            UIApplication.shared.delegate?.incrementActivityCounter()
            self.sessionManager.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in request.parameters {
                    if let representation = request.fileRepresentations[key] {
                        multipartFormData.append(value as! Data, withName: key, fileName: representation.fileName, mimeType: representation.mimeType)
                    } else {
                        multipartFormData.append(value as! Data, withName: key)
                    }
                }
            }, to: request.url,
               method: request.method,
               headers: request.headers,
               encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        progressHandler?(progress.fractionCompleted)
                    })
                    upload.validate().responseJSON(completionHandler: { (response) in
                        UIApplication.shared.delegate?.decrementActivityCounter()
                        switch (response.result) {
                        case .success(let result):
                            resolver.fulfill(result)
                            break
                        case .failure(let error):
                            resolver.reject(NetworkManager.parseError(error: error, response: response))
                        }
                    })
                case .failure(let encodingError):
                    UIApplication.shared.delegate?.decrementActivityCounter()
                    resolver.reject(encodingError)
                }
            })
        }
    }
    
}

extension NetworkManager {
    fileprivate static func parseError<T>(error: Error, response: DataResponse<T>) -> NSError {
        return NSError(domain: "com.avtolet.network",
                       code: response.response?.statusCode ?? (error as NSError).code,
                       userInfo: ["responseCode": response.response?.statusCode ?? -1])
    }
}
extension NSError {
    var statusCode: Int {
        return (userInfo["responseCode"] as? Int) ?? -1
    }
}

extension UIApplicationDelegate {
    func incrementActivityCounter() {
        if let delegate = self as? AppDelegate {
            delegate.networkActivityCounter += 1
        }
    }
    
    func decrementActivityCounter() {
        if let delegate = self as? AppDelegate {
            delegate.networkActivityCounter -= 1
        }
    }
}
