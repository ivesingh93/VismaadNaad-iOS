

//
//  SignUpVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 24/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown
import MaterialTextField

class SignUpVC: UIViewController {
    
    @IBOutlet weak var subview: UIView!
    // Fields
    @IBOutlet weak var txtEmailField: UITextField!
    @IBOutlet weak var txtFirstNameField: UITextField!
    @IBOutlet weak var txtLastNameField: UITextField!
    @IBOutlet weak var txtUsernameField: UITextField!
    @IBOutlet weak var txtPasswordField: UITextField!

    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewEmailInner: UIView!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewPasswordInner: UIView!

    
    @IBOutlet weak var stackViewName: UIStackView!
    @IBOutlet weak var stackViewEmail: UIStackView!

    @IBOutlet weak var lcBottomSignUpButton: NSLayoutConstraint!
    // var dropdown = DropDown()
    //var datePicker: MDDatePickerDialog?
    
    var loginSource: String?
    
    var socialMediaConnectionInfo: [String: AnyObject]?
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        super.viewDidDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animate()
    }
    func animate() {
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        subview.layer.addSublayer(gradient)
        
        animateGradient()

    }
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    }
    private func initialize() {
        addObservers()
        viewEmail.isHidden = true
        if let info = socialMediaConnectionInfo {
            viewPasswordInner.isHidden = true
            viewEmailInner.isHidden = true
            viewName.isHidden = true
            viewEmail.isHidden = false

            if info["type"] as! String == LoginSource.facebook {
                if let email = info["email"] as? String {
                    txtEmailField.text = email
                }
                if let first_name = info["first_name"] as? String {
                    txtFirstNameField.text = first_name
                }
                if let last_name = info["last_name"] as? String {
                    txtLastNameField.text = last_name
                }
            } else {
                if let email = info["email"] as? String {
                    txtEmailField.text = email
                }
                if let givenName = info["givenName"] as? String {
                    txtFirstNameField.text = givenName
                }
                if let familyName = info["familyName"] as? String {
                    txtLastNameField.text = familyName
                }
            }
         
        }
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.lcBottomSignUpButton.constant = keyboardSize.height + 10
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardDidHide(_ notification: Notification) {
        self.lcBottomSignUpButton.constant = 100
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Other methods
    func validateEmailFields() -> Bool {
        var errorMessage = ""
        if let _ = socialMediaConnectionInfo {
            if txtUsernameField.text!.count == 0 {
                errorMessage = Messages.enterUsername
            }
        } else {
        if txtEmailField.text!.count == 0 {
            errorMessage = Messages.enterEmail
        }
        else if txtEmailField.text!.isValidEmail() == false {
            errorMessage = Messages.invalidEmail
        }
        else if txtUsernameField.text!.count == 0 {
            errorMessage = Messages.enterUsername
        }
        else if txtPasswordField.text!.count < 5 {
            errorMessage = Messages.passwordStrength
        }
        }
        if errorMessage.count > 0 {
            Helper.showMessage(message: errorMessage, success: false)
            return false
        }
        return true
    }
    func validateNameFields() -> Bool {
        var errorMessage = ""
        if txtFirstNameField.text!.count == 0 {
            errorMessage = Messages.enterFirstName
        }
        else if txtLastNameField.text!.count == 0 {
            errorMessage = Messages.enterLastName
        }
        
        if errorMessage.count > 0 {
            Helper.showMessage(message: errorMessage, success: false)
            return false
        }
        return true
    }
    // MARK: - Actions
    func signUp() {
        NetworkManager.startLoader()
        var email = txtEmailField.text!
        if loginSource == LoginSource.facebook {
            if let id = socialMediaConnectionInfo!["id"] as? String {
                email = id
            }
        }
        let parameters = SignUp.parametersForSignUp(accountId: email, username: txtUsernameField.text!, password: txtPasswordField.text!, firstName: txtFirstNameField.text!, lastName: txtLastNameField.text!, /*dob: txtDOBField.text!, gender: txtGenderField.text!*/ sourceOfLogin: loginSource!)
        NetworkManager.sharedManager.postRequest(with: SignUp.signUpURL, parameters) { (status, error, result) in
            NetworkManager.stopLoader()
            if status {
                let statusCode = result["ResponseCode"].int
                if statusCode == 200 {
                    CoreDataService.saveLogin(self.txtUsernameField.text!, loginSource: self.loginSource!)
                    self.performSegue(withIdentifier: Segue.homeFromSignUp, sender: nil)
                    Helper.showMessage(message: Messages.signUpSuccess, success: true)
                } else {
                    Helper.showMessage(message: Messages.signUpFailure, success: false)
                }
            }
        }
    }
    @IBAction func btnSignUpClicked(_ sender: UIButton?) {
        view.endEditing(true)

        if viewName.isHidden == false {
            if validateNameFields() == true {
                UIView.animate(withDuration: 0.5) {
                    self.viewEmail.isHidden = false
                    self.viewName.isHidden = true
                }
            }
        } else if viewEmail.isHidden == false {
            if validateEmailFields() == true {
                view.endEditing(true)
                signUp()
            }
        }

    }
    
    @IBAction func btnBackClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func textDidChange(_ textField: MFTextField) {
        if textField == txtFirstNameField {
            
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if viewName.isHidden == false {
            if let txtField = self.stackViewName.viewWithTag(textField.tag + 1) as? UITextField {
                txtField.becomeFirstResponder()
                return true
            }
        }
        if viewEmail.isHidden == false {
            if let txtField = self.stackViewEmail.viewWithTag(textField.tag + 1) as? UITextField {
                txtField.becomeFirstResponder()
                return true
            }
        }
     
        btnSignUpClicked(nil)
        textField.resignFirstResponder()
        return true
    }
}
//extension SignUpVC: MDDatePickerDialogDelegate {
//    func datePickerDialogDidSelect(_ date: Date) {
//        txtDOBField.text = Helper.getDOB(date)
//    }
//}
extension SignUpVC: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animate()
    }
}
