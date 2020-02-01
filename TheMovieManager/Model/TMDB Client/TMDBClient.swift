//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = ""
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        static let tokenPath = "/authentication/token/new"
        static let authPath = "/authentication/token/validate_with_login"
        static let getSessionIdPath = "/authentication/session/new"
        static let webAuthURL = "https://api.themoviedb.org/authenticate/"
        static let logoutURL = "/authentication/session"
    
        
        
        case getWatchlist
        case getToken
        case authWithLogin
        case getSessionID
        case webAuth
        case logout
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getToken:
                return Endpoints.base +
                    TMDBClient.Endpoints.tokenPath + Endpoints.apiKeyParam
                
            case .authWithLogin:
                return Endpoints.base + Endpoints.authPath + Endpoints.apiKeyParam
                
            case .getSessionID:
                return Endpoints.base + Endpoints.getSessionIdPath + Endpoints.apiKeyParam
            case .webAuth :
                return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authonticate"
            case .logout:
                return Endpoints.base + Endpoints.logoutURL + Endpoints.apiKeyParam
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
    
    
    //MARK: Get the api token
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
                completionHandler(true , nil )
                print ( " The token is : \(token.request_token)")
            }catch{
                print (error.localizedDescription)
                completionHandler(false , error)
            }
            
        }
        
        task.resume()
    }
    
    
    //MARK: Auth with login post
    class func authWithLogin(userName:String , password:String , completionHandler:@escaping(Bool ,Error?)->Void){
        var request = URLRequest(url: Endpoints.authWithLogin.url)
        print ("The login url is : \(Endpoints.authWithLogin.url)")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        let loginRequest = LoginRequest(userName: userName , password: password, requestToken: Auth.requestToken)
         request.httpBody  = try! encoder.encode(loginRequest)
        print ("UserName : \(userName) Password:\(password)")
        print ("request body for get access token is : \(request.httpBody)")
       
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print ("Error in the data")
                completionHandler(false , error)
                return
            }
            let response1 = response as! HTTPURLResponse
            print ("The response code is : \(response1.statusCode)")
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(RequestTokenResponse.self, from: data)
                print (response)
                if (response.success == true){
                    completionHandler(true , nil)
                    Auth.requestToken = response.request_token
                    print ("The second token is : \(Auth.requestToken)")
                }else {
                    print ("Failed to login")
                    completionHandler(false , error)
                }
            }catch {
                completionHandler(false , error)
            }
        }
        task.resume()
    }
    
    
    //MARK: Get the Session ID
    class func getSessionID(completionHandler: @escaping (Bool , Error?)->Void){
        var request = URLRequest(url: Endpoints.getSessionID.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostMySession(request_token: Auth.requestToken)
        request.httpBody = try! JSONEncoder().encode(body)
        print ("The get session id url is : \(request.url!)")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print ("Error in response data")
                completionHandler(false , error)
                return
            }
            do {
                let result = try  JSONDecoder().decode(SessionResponse.self, from: data)
                completionHandler(true , nil)
                Auth.sessionId = result.session_id
                print ("The session id : \(result.session_id)")
            }catch{
                print (error.localizedDescription)
                completionHandler(false , error)
            }
        }
        task.resume()
    }
    
    
    
    //MARK: The logout call
    class func logout (completionHandler:@escaping()->Void){
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        let body = LogoutRequest(session_id: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completionHandler()
            
        }
        task.resume()
    }
}
