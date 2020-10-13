//
//  SettingsViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 OlivsMatic Pty Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var yourLogin: UILabel!
    @IBOutlet weak var registeredWith: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = UserDefaults.standard.string(forKey: "name")
        yourLogin.text = "Your login: " + (UserDefaults.standard.string(forKey: "email") ?? "none")
        registeredWith.text = "Registered with: \n" + (UserDefaults.standard.string(forKey: "businessFileName") ?? "none")
        errorMessage.text = ""
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logOffPressed(_ sender: Any) {
        UserDefaults.standard.set(false,forKey: "loggedIn")
        UserDefaults.standard.set("",forKey: "userToken")
        UserDefaults.standard.set("",forKey: "name")
        UserDefaults.standard.set("",forKey: "email")
        removeBusinessFile()
        showViewController(isLogin: true)
    }
    
    @IBAction func changeBusinessFilePressed(_ sender: Any) {
        showViewController(isLogin: false)
    }
    
    @IBAction func syncPressed(_ sender: Any) {
        errorMessage.textColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        errorMessage.text = "Syncing..."
        SQLHelper.instance.sync(){(success, message) in
            self.errorMessage.textColor = success ? #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.errorMessage.text = message
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                self.errorMessage.text = ""
            }
        }
    }
    
    private func showViewController(isLogin: Bool){
            let delegate = self.view.window?.windowScene?.delegate as? SceneDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var vc: UIViewController
        if !isLogin{
            vc = storyboard.instantiateViewController(withIdentifier: "BusinessFileVC") as!
                BusinessFileViewController
        }
        else {
            vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as!
                LoginViewController
        }
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            delegate?.window?.overrideUserInterfaceStyle = .light
            delegate?.window?.rootViewController = nav
            delegate?.window?.makeKeyAndVisible()
    }
    
    private func removeBusinessFile(){
        UserDefaults.standard.set(false,forKey: "dbSelected")
        UserDefaults.standard.set("",forKey: "dbToken")
        UserDefaults.standard.set("",forKey: "businessFile")
    }
    
    @IBAction func goBack(){
        dismiss(animated: true)
    }



    
}
