//
//  NetworkManager.swift
//  Player
//
//  Created by B2BConnect on 21/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON

typealias ServiceResponse = (_ status:Bool, _ response:HTTPURLResponse?,_ responseDict:JSON) -> Void

class NetworkManager: NSObject {
    static let sharedManager = NetworkManager()
    public var sessionManager: Alamofire.SessionManager
    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
    
    var activityData:ActivityData!
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.listener = { status in
            switch status {
                
            case .notReachable:
                print("The network is not reachable")
                
            case .unknown :
                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                
            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
                
            }
        }
        
        // start listening
        reachabilityManager?.startListening()
    }

    
    override init(){
        activityData = ActivityData()
        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.sehajbani.backgroundtransfer"))
    }
    
    
    //MARK:- Almofire Service Method
    func postRequest(with subUrl:String, _ parameters:[String: String], _ onCompletion: @escaping ServiceResponse) -> Void {
        if reachabilityManager?.isReachable == false {
            NetworkManager.stopLoader()
            Helper.showMessage(message: Messages.noInternet, success: false)
            return
        }
        let urlStr = API.baseURL + subUrl
        let url = Foundation.URL(string: urlStr)
        print(parameters)
        print(url)
        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            print(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onCompletion(true, response.response, json)
            case .failure(let error):
                print(error)
                onCompletion(false, response.response, [:])
            }
        }
            .responseString { response in
                print("String:\(response.result.value)")
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        print(data)
                    }
                    
                case .failure(_):
                    print("Error message:\(response.result.error)")
                    break
                }
        }

    }
    
    func postRequestWithAnyDataType(with subUrl:String, _ parameters:[String: Any], _ onCompletion: @escaping ServiceResponse) -> Void {
        if reachabilityManager?.isReachable == false {
            NetworkManager.stopLoader()
            Helper.showMessage(message: Messages.noInternet, success: false)
            return
        }
        let urlStr = API.baseURL + subUrl
        let url = Foundation.URL(string: urlStr)
        
        print(parameters)
        print(url!)

        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            print(response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onCompletion(true, response.response, json)
            case .failure(let error):
                print(error)
                onCompletion(false, response.response, [:])
            }
        }
            .responseString { response in
                print("String:\(response.result.value)")
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        print(data)
                    }
                    
                case .failure(_):
                    print("Error message:\(response.result.error)")
                    break
                }
        }
    }
    
    func postRequestWithArrayEncoded(with subUrl:String, _ parameters:[[String: Any]], _ onCompletion: @escaping ServiceResponse) -> Void {
        if reachabilityManager?.isReachable == false {
            NetworkManager.stopLoader()
            Helper.showMessage(message: Messages.noInternet, success: false)
            return
        }
        let urlStr = API.baseURL + subUrl
        let url = Foundation.URL(string: urlStr)
        print(url!)

        print(parameters)

        Alamofire.request(url!, method: .post, encoding: JSONArrayEncoding(array: parameters), headers: nil).responseJSON { response in
               print(response)

            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onCompletion(true, response.response, json)
            case .failure(let error):
                print(error)
                onCompletion(false, response.response, [:])
            }
        }

    }
    func getRequestWithURLEncoding(with subUrl:String, _ parameters:[String: String], _ onCompletion: @escaping ServiceResponse) -> Void {
        if reachabilityManager?.isReachable == false {
            NetworkManager.stopLoader()
            Helper.showMessage(message: Messages.noInternet, success: false)
            return
        }
        let urlStr = API.baseURL + subUrl
        let url = Foundation.URL(string: urlStr)
        Alamofire.request(url!, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onCompletion(true, response.response, json)
            case .failure(let error):
                print(error)
                onCompletion(false, response.response, [:])
            }
        }
    }
    
    func getRequest(with subUrl:String, _ parameters:[String: String]?, _ onCompletion: @escaping ServiceResponse) -> Void {
        if reachabilityManager?.isReachable == false {
            NetworkManager.stopLoader()
            Helper.showMessage(message: Messages.noInternet, success: false)
            return
        }
        let urlStr = (API.baseURL + subUrl).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = Foundation.URL(string: urlStr!)
        Alamofire.request(url!, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            print("\(response)")
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onCompletion(true, response.response, json)
            case .failure(let error):
                print(error)
                onCompletion(false, response.response, [:])
            }
        }
    }
    
    
}


struct API {
    static let baseURL = "http://vismaadnaad.com/api/"
    static let shabadBaseURL = "https://s3.eu-west-2.amazonaws.com/vismaadnaad/Raagis/"
}

struct EndPointMethod {
    static let raagiInfo = "raagiRoutes/raagi_info"
    static let shabads = "raagis/<raagi_name>/shabads"
    static let shabadLyrics = "linesFrom/<starting_id>/linesTo/<ending_id>"
    static let playlists = "/playlists/"
    static let shabadListeners = "/raagiRoutes/shabadListeners/"

}

struct SignUp {
    static let signUpURL = "userRoutes/signup"
    static func parametersForSignUp(accountId: String, username: String, password: String, firstName: String, lastName: String,/* dob: String, gender: String,*/ sourceOfLogin: String) -> [String : String] {
        
        var parameter = [String : String]()
        parameter["account_id"] = accountId
        parameter["username"] = username
        parameter["first_name"] = firstName
        parameter["last_name"] = lastName
        parameter["source_of_account"] = sourceOfLogin
        if sourceOfLogin == LoginSource.email {
            parameter["password"] = password
        } 
        return parameter
    }
}

struct Login {
    static let loginURL = "userRoutes/authenticate"
    static func parametersForLogin(username: String, password: String, loginSource: String) -> [String : String] {
        
        var parameter = [String : String]()
        if username.isValidEmail() == true {
            parameter["account_id"] = username
        } else {
            parameter["username"] = username
        }
        if loginSource == LoginSource.facebook {
            parameter["account_id"] = username
        }
        parameter["source_of_account"] = loginSource
        if loginSource == LoginSource.email {
            parameter["password"] = password
        }
        return parameter
    }
}

struct PlaylistMethod {
    static let createURL = "userRoutes/createPlaylist"
    static func parametersForCreatePlaylist(username: String, playlist_name: String) -> [String : String] {
        var parameter = [String : String]()
        parameter["username"] = username
        parameter["playlist_name"] = playlist_name
        return parameter
    }
    static let deleteURL = "userRoutes/deletePlaylist"
    static func parametersForDeletePlaylist(username: String, playlist_name: String) -> [String : String] {
        var parameter = [String : String]()
        parameter["username"] = username
        parameter["playlist_name"] = playlist_name
        return parameter
    }
    static let addShabadURL = "userRoutes/addShabads"
    static func parametersForAddShabad(username: String, playlist_name: String, id: Int/*raagi_name: String, sathaayi_id: String, shabad_english_title: String, starting_id: String, ending_id: String, shabad_url: String*/) -> [String : Any] {
        var parameter = [String : Any]()
        parameter["username"] = username
        parameter["playlist_name"] = playlist_name
        parameter["id"] = id
//        parameter["raagi_name"] = raagi_name
//        parameter["sathaayi_id"] = sathaayi_id
//        parameter["shabad_english_title"] = shabad_english_title
//        parameter["starting_id"] = starting_id
//        parameter["ending_id"] = ending_id
//        parameter["shabad_url"] = shabad_url
        return parameter
    }
    static let removeShabadURL = "userRoutes/removeShabads"
    static func parametersForRemoveShabad(username: String, playlist_name: String, id: Int/*raagi_name: String, sathaayi_id: String, shabad_english_title: String, starting_id: String, ending_id: String, shabad_url: String*/) -> [String : Any] {
        var parameter = [String : Any]()
        parameter["username"] = username
        parameter["playlist_name"] = playlist_name
        parameter["id"] = id
        return parameter
    }
}
struct ShabadLike {
    static let shabadLikeURL = "userRoutes/updateShabadLike"
    static func parametersForShabadLike(username: String, id: Int, like: Bool) -> [String : Any] {
        
        var parameter = [String : Any]()
        parameter["username"] = username
        parameter["id"] = id
        parameter["like"] = like
        return parameter
    }
}
//MARK: - Loader Helper Method
typealias LoaderHandlers = NetworkManager
extension LoaderHandlers {
    
    class func startLoader() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(NetworkManager.sharedManager.activityData)
    }
    
    class func stopLoader() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}


//MARK: - Parser Helper
typealias ParserHandlers = NetworkManager
extension ParserHandlers {
    class func valueCheck(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
}

struct JSONArrayEncoding: ParameterEncoding {
    private let array: [Parameters]
    
    init(array: [Parameters]) {
        self.array = array
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
}
