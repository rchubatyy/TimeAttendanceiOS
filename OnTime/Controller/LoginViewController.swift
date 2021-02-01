//
//  LoginViewController.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import UIKit
import Alamofire
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var logo: OurLogoAndInfo!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLink: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var learnMoreAndRegisterLink: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoSize: NSLayoutConstraint!
    @IBOutlet weak var loginPosition: NSLayoutConstraint!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        emailField.delegate = self
        passwordField.delegate = self
        errorMessage.text = ""
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        let forgotTap = UITapGestureRecognizer(target: self, action: #selector(toForgotPassword))
        forgotPasswordLink.addGestureRecognizer(forgotTap)
        let registerTap = UITapGestureRecognizer(target: self, action: #selector(toLearnMoreAndRegister))
        learnMoreAndRegisterLink.addGestureRecognizer(registerTap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        locationManager.requestWhenInUseAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.textContentType == UITextContentType.emailAddress{
        passwordField.becomeFirstResponder()
        }
        else{
            dismissKeyboard()
            loginButtonPressed(loginButton!)
        }
        return true
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        errorMessage.textColor = #colorLiteral(red: 0, green: 0.6249343753, blue: 1, alpha: 1)
        errorMessage.text = "Logging in..."
        if let email = emailField.text, let password = passwordField.text{
            LoginService.instance.login(withEmail: email, andPassword: password){(success, message) in
                if success{
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    self.errorMessage.text = ""
                    self.toDBScreen()
                }
                else {
                    self.errorMessage.textColor =  #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
                    self.errorMessage.text = message
                }
            }
        }
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height{
            if  loginPosition.constant == 0{
            let startPos = loginStackView.frame.minY
            let offset = keyboardHeight - (UIScreen.main.bounds.height - loginStackView.frame.maxY) + 10
            loginPosition.constant -= offset
            if startPos - offset < logo.frame.maxY {
            resizeLogo(to: 0.04)
        }
            }
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification){
        if loginPosition.constant != 0{
        loginPosition.constant = 0
        resizeLogo(to: 0.08)
        }
    }
    
    func toDBScreen(){
        performSegue(withIdentifier: "LOG_IN", sender: nil)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func resizeLogo(to size: CGFloat){
        let newConstraint = logoSize.constraintWithMultiplier(size)
        view.removeConstraint(logoSize)
        view.addConstraint(newConstraint)
        view.layoutIfNeeded()
        logoSize = newConstraint
        }
    
    @objc func toForgotPassword(sender: UITapGestureRecognizer){
        print("should be called")
        if let url = URL(string: "https://s1.olivs.app/0/en-au/olivs/forgot-user-login-password") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func toLearnMoreAndRegister(sender: UITapGestureRecognizer){
        if let url = URL(string: "https://olivs.app/ontime") {
            UIApplication.shared.open(url)
        }
    }
    
    
}


