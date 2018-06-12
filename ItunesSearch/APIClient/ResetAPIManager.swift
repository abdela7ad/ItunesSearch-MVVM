//
//  ResetAPIManager.swift
//  ItunesSearch
//
//  Created by Abdelahad on 6/10/18.
//  Copyright © 2018 Abdelahad. All rights reserved.
//

import Foundation


//https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/

//https://itunes.apple.com/search?term=Ahla W Ahla&media=music&limit=10



 protocol APISericeRequest {
    /// The target's base `URL`.
    var baseURL: URL { get }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    /// The type of HTTP task to be performed.
    var request: URLRequest { get }
}

public enum ItunesAPI {
    case search(query:String,media:String,limit:Int)
}

extension ItunesAPI : APISericeRequest {
   
    
    var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }
    
    var path: String {
        switch self {
        case  .search:
            return "/search"
        }
    }
    
    var request: URLRequest {
        switch self {
           case let .search(query, media, limit):
            return createURLRequestQuery(paramters: ["term":query,"media":media,"limit":limit])
        }
    }
    
    
    // Format URL URLRequestQuery
    func createURLRequestQuery(paramters: [String: Any]?) -> URLRequest {
        
        let url = self.baseURL.absoluteString + self.path
        let  query  =  paramters?.map({"\($0.key)=\($0.value)"}).joined(separator: "&")
        var components = URLComponents(url: URL(string: url)!, resolvingAgainstBaseURL: true)!
        components.query = query
        
        return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
    }
    
    
}
class APIManager {

   
    static let shared = APIManager()
   
    

    func request(_ target:ItunesAPI, succes successCallback:@escaping (Data)->Void,
                 failure failureCallback: ((Any?,Error?) -> Void)?) {

        let session = URLSession.shared
        let dataTask = session.dataTask(with: target.request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                
                if let  failure = failureCallback {
                    failure(nil,error)
                }
            } else {
                if let data = data {
                    successCallback(data)
                }else{
                    if let  failure = failureCallback {
                        failure(nil,error)
                    }
                }
            }
        })
        
        dataTask.resume()

    }

}
