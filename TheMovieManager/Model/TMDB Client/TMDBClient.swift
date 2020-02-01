//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "9f649f80c1130758605a8c9e433c1cdb"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        static let tokenPath = "/authentication/token/new"
        
        case getWatchlist
        case getToken
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getToken:
                return Endpoints.base +
                    TMDBClient.Endpoints.tokenPath + Endpoints.apiKeyParam
                
            }
        }
        
        var url: URL {
            
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    
    class func getApiToke(completionHandler:@escaping(Bool , Error?)->Void){
        let task = URLSession.shared.dataTask(with: Endpoints.getToken.url) { (data, response, error) in
            print ("The url for token is : \(Endpoints.getToken.url)")
            guard let data = data else {
                print ("Error in the data")
                 completionHandler(false , error)
                return
            }
            let decoder = JSONDecoder()
            do{
                let token = try  decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken   = token.request_token
                print ( " The token is : \(token.request_token)")
            }catch{
                print (error.localizedDescription)
                completionHandler(false , error)
            }
            
        }
        
        task.resume()
    }
}
