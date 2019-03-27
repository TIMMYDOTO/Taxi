//
//  Request.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 17.07.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire

class CommonRequest {
    var url: String!
    var headers: [String: String]!
    var parameters: [String: Any]!
    var method: Alamofire.HTTPMethod!
    var encoding:ParameterEncoding = URLEncoding.default
    var timeout: TimeInterval = 30.0
    
    
    required init(url: String, method: Alamofire.HTTPMethod) {
        self.url = url
        self.headers = [String: String]()
        self.parameters = [String: Any]()
        self.method = method
    }
    
    class func create(url: String, method: Alamofire.HTTPMethod) -> Self {
        let request = self.init(url: url, method: method)
        .withBaseHeaders()
        .withAuth()
        return request
    }
    
    func withParameter(key: String, value: Any) -> Self {
        self.parameters[key] = value
        return self
    }
    
    func withHeader(key: String, value: String) -> Self {
        self.headers[key] = value
        return self
    }
    
}

extension CommonRequest {
    func withBaseHeaders() -> Self {
        return self
    }
}


struct FileRepresentation {
    let fileName: String
    let mimeType: String
}

class MultipartRequest: CommonRequest {
    
    var fileRepresentations = [String: FileRepresentation]()
    
    func withTextParameter(key: String, value: String, encoding: String.Encoding = .utf8) -> Self {
        return self.withParameter(key: key, value: value.data(using: encoding)!)
    }
    
    func withFileParameter(key: String, value: Data, representation: FileRepresentation) -> Self {
        fileRepresentations[key] = representation
        return self.withParameter(key: key, value: value)
    }
    
    override func withParameter(key: String, value: Any) -> Self {
        guard let value = value as? Data else { fatalError("Поддерживаются параметры только типа Data") }
        self.parameters[key] = value
        return self
    }
}

final class CodableRequest: CommonRequest {
    
    func withObject<T: Codable>(_ object: T, options: JSONSerialization.ReadingOptions = .allowFragments) throws -> Self {
        let data = try JSONEncoder().encode(object)
        guard let json = try JSONSerialization.jsonObject(with: data, options: options) as? JSON else { throw RCError.incorrectData }
        self.parameters = json
        self.encoding = JSONEncoding.default
        return self
    }
    
    override func withParameter(key: String, value: Any) -> Self {
        #if DEBUG
        print("Can not use method withParameter:value: in CodableRequest, use withObject:options:")
        #endif
        return self
    }
    
}

//MARK: Pagination

extension CommonRequest {
    func withAuth() -> Self {
        guard let authToken = User.current.accessToken else { return self }
        let _ = self.withParameter(key: "token", value: authToken)
        return self
    }
}
