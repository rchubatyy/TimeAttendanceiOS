//
//  SettingsViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 Business Tax & Money House. All rights reserved.
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
        registeredWith.text = "Registered with: " + (UserDefaults.standard.string(forKey: "businessFileName") ?? "none")
        errorMessage.text = ""
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logOffPressed(_ sender: Any) {
        UserDefaults.standard.set(false,forKey: "loggedIn")
        UserDefaults.standard.set("",forKey: "userToken")
        UserDefaults.standard.set("",forKey: "name")
        UserDefaults.standard.set("",forKey: "email")
        removeBusinessFile()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func changeBusinessFilePressed(_ sender: Any) {
        removeBusinessFile()
        let vc = self.navigationController?.viewControllers[1] as! BusinessFileViewController
        self.navigationController?.popToViewController(vc, animated: false)
    }
    
    @IBAction func syncPressed(_ sender: Any) {
        errorMessage.textColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        errorMessage.text = "Syncing..."
        SQLHelper.instance.sync(){(success, message) in
            self.errorMessage.textColor = success ? #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.errorMessage.text = message
        }
    }
    
    private func removeBusinessFile(){
        UserDefaults.standard.set(false,forKey: "dbSelected")
        UserDefaults.standard.set("",forKey: "dbToken")
        UserDefaults.standard.set("",forKey: "businessFile")
    }
    
    @IBAction func goBack(){
        self.navigationController?.popViewController(animated: false)
    }



    
}
