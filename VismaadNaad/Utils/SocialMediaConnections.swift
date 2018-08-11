
//  Colors.swift
//  SehajBani
//
//  Created by Jasmeet on 24/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import FBSDKLoginKit
import GoogleSignIn

typealias SocialMediaCompletionBlock = (_ status: Bool, _ error: Error?, _ responseDict: [String : AnyObject]?) -> Void

class SocialMediaConnections: NSObject {

    weak var currentViewController: UIViewController?
    
    var completionBlock: SocialMediaCompletionBlock?
    
    //Facebook handling
    func getFacebookDetail(for viewController: UIViewController, completionHandler: @escaping SocialMediaCompletionBlock) {
         completionBlock = completionHandler
         currentViewController = viewController
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: viewController, handler: { [unowned self] (result, error) -> Void in
            
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if(fbloginresult.isCancelled) {
                    self.completionBlock!(false, error, nil)
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    self.returnUserData()
                } else {
                    self.completionBlock!(false, error, nil)
                }
            } else {
                print("Error in facebook SDK: \(error)")
                self.completionBlock!(false, error, nil)
            }
        })

    }
    
    
    func returnUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { [unowned self] (connection, result, error) -> Void in
                
                if let error = error {
                    print("Error: \(error)")
                    self.completionBlock!(false, error, nil)
                } else {
                    print(result)
                        let data:[String:AnyObject] = result as! [String : AnyObject]
                    
                    var resultData = [String: AnyObject]()
                    resultData["type"] = LoginSource.facebook as AnyObject?
                    resultData["id"] = data["id"] as AnyObject?
                    resultData["name"] = data["name"] as AnyObject?
                    resultData["first_name"] = data["first_name"] as AnyObject?
                    resultData["last_name"] = data["last_name"] as AnyObject?
                    resultData["email"] = data["email"] as AnyObject?
                    self.completionBlock!(true, error, resultData)
                }
            })
        }
    }
    
    //MARK: - Google Plus 
    func getGoogleDetail(for viewController: UIViewController, completionHandler: @escaping SocialMediaCompletionBlock) {
        completionBlock = completionHandler
        currentViewController = viewController
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
}

extension SocialMediaConnections: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            
            print("userId:\(userId), idToken:\(idToken), fullName:\(fullName), givenName:\(givenName), familyName:\(familyName), email:\(email)")
            var resultData = [String: AnyObject]()
            resultData["type"] = LoginSource.google as AnyObject?
            resultData["id"] = userId as AnyObject?
            resultData["name"] = fullName as AnyObject?
            resultData["givenName"] = givenName as AnyObject?
            resultData["familyName"] = familyName as AnyObject?
            resultData["name"] = fullName as AnyObject?
            resultData["email"] = email as AnyObject?
            
            
            self.completionBlock!(true, error, resultData)
            
        } else {
            self.completionBlock!(false, error, nil)
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error)
        GIDSignIn.sharedInstance().signOut()
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
       // self.completionBlock!(false, error, nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.currentViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        GIDSignIn.sharedInstance().signOut()
        self.currentViewController?.dismiss(animated: true, completion: nil)
    }
    
}
