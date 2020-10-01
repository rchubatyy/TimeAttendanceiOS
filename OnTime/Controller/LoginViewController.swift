//
//  LoginViewController.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLink: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var learnMoreAndRegisterLink: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if LoginService.instance.loggedIn{
            //toDBScreen()
        }
        emailField.delegate = self
        passwordField.delegate = self
        errorMessage.text = ""
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        errorMessage.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
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
                    self.errorMessage.textColor =  #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                    self.errorMessage.text = message
                }
            }
        }
    }
    
    func toDBScreen(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BusinessFileVC") as! BusinessFileViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
    
}
