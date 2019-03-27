//
//  NetworkRequests.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/5/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation
import Alamofire
class NetworkRequests {
    
    private init() { }
    static let shared = NetworkRequests()
    
    func postRequest(url: String, parameters: Parameters, onSuccess: @escaping (_ response: NSDictionary)  -> ()) {
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON {
            response in
            switch response.result {
            case .success:
              
                if let JSON = response.result.value as? NSDictionary {
                 
                    onSuccess(JSON)
                }
                
                break
            case .failure(let error):
             
                print(error)
            }
        }
    }
    
    
    
    func getRequest(url: String, parameters: Parameters, onSuccess: @escaping (_ response: DataResponse<Any>) -> ()) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response:DataResponse<Any>) in
            switch response.result {
            case .success:
                    onSuccess(response)
                break
            
            case .failure(let error):
                print("er", error)
            }
        }
    }
   
}
