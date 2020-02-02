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
        static let favPath = "/account/"
        
        
        
        case getWatchlist
        case getToken
        case authWithLogin
        case getSessionID
        case webAuth
        case logout
        case getFavList
        case getSearchedList(String)
        case addToFavorite
        case addToWatchList
        
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
            case .getFavList:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
              
            case .getSearchedList(let word):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .addToFavorite:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
               
            case .addToWatchList:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            }
        }
        
        var url: URL {
            
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results , nil )
            }else {
                completion([] , error)
            }
        }
    }
    
    class func getFavorites(completionHandler:@escaping([Movie] , Error?)->Void){
        taskForGetRequest(url: Endpoints.getFavList.url, responseType: MovieResults.self) { (response, error) in
            if let response = response {
                completionHandler(response.results , nil)
            }else {
                completionHandler([] , error)
            }
        }
    }
    
    class func search(word:String , completionHandler:@escaping([Movie] , Error?)->Void){
        taskForGetRequest(url: Endpoints.getSearchedList(word).url, responseType: MovieResults.self) { (response, error) in
            if let response = response{
                completionHandler(response.results , nil)
            }else {
                completionHandler([] , error)
            }
        }
    }
    
    class func addToWatchList(movieId:Int , isWatchList:Bool , completionHandler:@escaping(Bool , Error?)->Void){
        let body = MarkWatchList(media_type: "movie", media_id: movieId, watchlist: isWatchList)
        taskForPostRequest(url: Endpoints.addToWatchList.url, body: body, responseType: TMDBResponse.self) { (response, error) in
            if let response = response {
                completionHandler(
                    response.status_code == 1  ||
                    response.status_code == 12 ||
                    response.status_code == 13
                    
                    , nil)
            }else{
                completionHandler(false , error)
            }
        }
    }
    
    class func addToFavorite(movieId:Int , isFavorite:Bool , completionHandler:@escaping(Bool , Error?)->Void){
           let body = MarkFavorite(media_type: "movie", media_id: movieId, favorite: isFavorite)
           taskForPostRequest(url: Endpoints.addToFavorite.url, body: body, responseType: TMDBResponse.self) { (response, error) in
               if let response = response {
                   completionHandler(
                       response.status_code == 1  ||
                       response.status_code == 12 ||
                       response.status_code == 13
                       
                       , nil)
               }else{
                   completionHandler(false , error)
               }
           }
       }
       
    
    //MARK: Get the api token
    class func getApiToke(completionHandler:@escaping(Bool , Error?)->Void){
        taskForGetRequest(url: Endpoints.getToken.url, responseType: RequestTokenResponse.self) { (response, error) in
            if let response = response {
                print ("The request token is : \(response.request_token)")
                Auth.requestToken   = response.request_token
                completionHandler(true , nil)
            }else {
                completionHandler(false , error)
            }
        }
        
        
    }
    
    
    //MARK: Auth with login post
    class func authWithLogin(userName:String , password:String , completionHandler:@escaping(Bool ,Error?)->Void){
        let loginRequest = LoginRequest(userName: userName , password: password, requestToken: Auth.requestToken)
        taskForPostRequest(url: Endpoints.authWithLogin.url, body: loginRequest, responseType: RequestTokenResponse.self) { (response, error) in
            if let response = response{
                
                Auth.requestToken = response.request_token
                print ("The second token is : \(Auth.requestToken)")
                completionHandler(true , nil)
            }else {
                completionHandler(false , error)
            }
        }
        
        
    }
    
    
    //MARK: Get the Session ID
    class func getSessionID(completionHandler: @escaping (Bool , Error?)->Void){
        let body = PostMySession(request_token: Auth.requestToken)
        taskForPostRequest(url: Endpoints.getSessionID.url, body: body, responseType: SessionResponse.self) { (response, error) in
            if let response = response {
                completionHandler(true , nil)
                Auth.sessionId = response.session_id
                print ("The session id : \(response.session_id)")
            }else {
                completionHandler(false , error)
            }
        }
        
        
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
    
    class func taskForGetRequest<ResponseType:Decodable>(url:URL , responseType:ResponseType.Type , completionHandler:@escaping(ResponseType? , Error?)->Void){
        let task = URLSession.shared.dataTask(with:url ) { data, response, error in
            print ("The url for get request is : \(url)")
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            DispatchQueue.main.async {
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    print ("The response object is : \(responseObject)")
                    
                    completionHandler(responseObject, nil)
                    
                    
                } catch {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPostRequest<RequestType:Encodable , ResponseType:Decodable>(url:URL , body:RequestType , responseType:ResponseType.Type , completionHandler:@escaping(ResponseType? ,Error?)->Void){
        
        var request = URLRequest(url: url)
        print ("The request url is : \(url)")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody  = try! encoder.encode(body)
        
        print ("request body  is : \(request.httpBody!)")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print ("Error in the data")
                completionHandler(nil , error)
                return
            }
            let response1 = response as! HTTPURLResponse
            print ("The response code is : \(response1.statusCode)")
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(ResponseType.self, from: data)
                print (response)
                DispatchQueue.main.async {
                    completionHandler(response , nil)
                }
                
            }catch {
                completionHandler(nil , error)
            }
        }
        
        
        task.resume()
    }
    
}
