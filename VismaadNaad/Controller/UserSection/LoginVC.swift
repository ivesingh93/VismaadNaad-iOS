
//
//  LoginVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 24/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SwiftMessages
import RZTransitions

class LoginVC: UIViewController {
    
    // Fields
    @IBOutlet weak var txtEmailField: UITextField!
    @IBOutlet weak var txtPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    let socialMediaConnections = SocialMediaConnections()
    var socialMediaInfo: [String: AnyObject]?
    var loginSource  = LoginSource.email
    var presentInteractionController: RZTransitionInteractionController?
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    private func initialize() {
        if let _ = CoreDataService.getLogin() {
            self.performSegue(withIdentifier: Segue.home, sender: nil)
        }
        presentInteractionController = RZVerticalSwipeInteractionController()
        if let vc = presentInteractionController as? RZVerticalSwipeInteractionController {
            vc.nextViewControllerDelegate = self;
            vc.attach(self, with: .present)
        }
        RZTransitionsManager.shared().setAnimationController( RZCirclePushAnimationController(),
                                                              fromViewController:type(of: self),
                                                              for:.presentDismiss);

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Other methods
    func validateFields() -> Bool {
        var errorMessage = ""
        if txtEmailField.text!.count == 0 {
            errorMessage = Messages.enterUsername
        }
        else if txtPasswordField.text!.count < 5 {
            errorMessage = Messages.passwordStrength
        }
        if errorMessage.count > 0 {
            Helper.showMessage(message: errorMessage, success: false)
            return false
        }
        return true
    }
    func signIn(_ email: String, _ password: String) {
        NetworkManager.startLoader()
       
        NetworkManager.sharedManager.postRequest(with: Login.loginURL, Login.parametersForLogin(username: email, password: password, loginSource: loginSource)) { (status, error, result) in
            NetworkManager.stopLoader()
            if status {
                let statusCode = result["ResponseCode"].int
                if statusCode == 200 {
                    CoreDataService.saveLogin(result["username"].stringValue, loginSource: self.loginSource)
                    self.performSegue(withIdentifier: Segue.home, sender: nil)
                } else {
                    if self.loginSource != LoginSource.email {
                        self.btnSignUpClicked(nil)
                    } else {
                        Helper.showMessage(message: Messages.loginFailed, success: false)
                    }
                }
            } else {
                if self.loginSource != LoginSource.email {
                    self.btnSignUpClicked(nil)
                } else {
                    Helper.showMessage(message: Messages.loginFailed, success: false)
                }
            }
        }
    }
    // MARK: - Actions
    @IBAction func btnShowPasswordClicked(_ sender: UIButton) {
        txtPasswordField.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    @IBAction func btnLoginClicked(_ sender: UIButton?) {
         view.endEditing(true)
        if validateFields() == true {
            loginSource = LoginSource.email
            signIn(txtEmailField.text!, txtPasswordField.text!)
        }
    }
    
    @IBAction func btnFBLoginClicked(_ sender: UIButton) {
        socialMediaConnections.getFacebookDetail(for: self) { (status, error, response) in
            if let _ = error {
                Helper.showMessage(message: error!.localizedDescription, success: false)
            } else {
                if let response = response {
                    self.loginSource = LoginSource.facebook
                    self.socialMediaInfo = response
                    if let id = response["id"] as? String {
                        self.signIn(id, "")
                    } else {
                         self.btnSignUpClicked(nil)
                    }
                }
            }
        }
    }
    
    @IBAction func btnGoogleLoginClicked(_ sender: UIButton) {
        socialMediaConnections.getGoogleDetail(for: self) { (status, error, response) in
            if let _ = error {
                Helper.showMessage(message: error!.localizedDescription, success: false)
            } else {
                if let response = response {
                    self.loginSource = LoginSource.google
                    self.socialMediaInfo = response
                    if let email = response["email"] as? String {
                        self.signIn(email, "")
                    } else {
                         self.btnSignUpClicked(nil)
                    }
                }
            }
        }
    }
    
    @IBAction func btnSignUpClicked(_ sender: UIButton?) {
        self.performSegue(withIdentifier: Segue.signUp, sender: nil)
      //  present(nextSimpleColorViewController(), animated:true, completion:({}));
    }
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        CoreDataService.deleteLogin()
        self.performSegue(withIdentifier: Segue.home, sender: sender)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.signUp {
            let destinationVc = segue.destination as! SignUpVC
            destinationVc.socialMediaConnectionInfo = socialMediaInfo
            destinationVc.loginSource = loginSource
        }
    }
    
}
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let txtField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            txtField.becomeFirstResponder()
            return true
        }
        self.btnLoginClicked(nil)
        textField.resignFirstResponder()
        return true
    }
}
extension LoginVC: RZTransitionInteractionControllerDelegate {
    
    func nextSimpleViewController() -> UIViewController {
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: LoginVC.className) as! LoginVC
        newVC.transitioningDelegate = RZTransitionsManager.shared()
        return newVC;
    }
    
    func nextSimpleColorViewController() -> UIViewController {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: SignUpVC.className) as! SignUpVC
        signUpVC.socialMediaConnectionInfo = socialMediaInfo
        signUpVC.loginSource = loginSource
        signUpVC.transitioningDelegate = RZTransitionsManager.shared()

        // Create a dismiss interaction controller that will be attached to the presented
        // view controller to allow for a custom dismissal
        let dismissInteractionController = RZVerticalSwipeInteractionController()
        dismissInteractionController.attach(signUpVC, with: .dismiss)
        RZTransitionsManager.shared().setInteractionController(dismissInteractionController,
                                                               fromViewController:type(of: self),
                                                               toViewController:nil,
                                                               for:.dismiss)
        return signUpVC
    }
    
    func nextViewControllerForInteractor(interactor: RZTransitionInteractionController) -> UIViewController {
        if (interactor is RZVerticalSwipeInteractionController) {
            return nextSimpleColorViewController();
        }
        else {
            return nextSimpleViewController();
        }
    }
    
}
