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
    @IBOutlet weak var websiteLink: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = UserDefaults.standard.string(forKey: "name")
        yourLogin.text = "Your login: " + (UserDefaults.standard.string(forKey: "email") ?? "none")
        registeredWith.text = "Registered with: \n" + (UserDefaults.standard.string(forKey: "businessFileName") ?? "none")
        errorMessage.text = ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewWebsite))
        websiteLink.addGestureRecognizer(tap)
    }
    
    
    @IBAction func logOffPressed(_ sender: Any) {
        LoginService.instance.logout()
        removeBusinessFile()
        showViewController(isLogin: true)
    }
    
    @IBAction func changeBusinessFilePressed(_ sender: Any) {
        showViewController(isLogin: false)
    }
    
    @IBAction func syncPressed(_ sender: Any) {
        errorMessage.textColor = #colorLiteral(red: 0, green: 0.6249343753, blue: 1, alpha: 1)
        errorMessage.text = "Syncing..."
        SQLHelper.instance.sync(){(success, message) in
            self.errorMessage.textColor = success ? #colorLiteral(red: 0, green: 0.6249343753, blue: 1, alpha: 1) : #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            self.errorMessage.text = message
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                self.errorMessage.text = ""
            }
        }
    }
    
    private func showViewController(isLogin: Bool){
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
        if #available(iOS 13.0, *) {
            let delegate = self.view.window?.windowScene?.delegate as? SceneDelegate
        
            //delegate?.window?.overrideUserInterfaceStyle = .light
            delegate?.window?.rootViewController = nav
            delegate?.window?.makeKeyAndVisible()
            delegate?.window?.overrideUserInterfaceStyle = .dark
        }
        else{
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.window?.rootViewController = nav
            delegate?.window?.makeKeyAndVisible()
        }
        dismiss(animated: true)
        
    }
    
    private func removeBusinessFile(){
        UserDefaults.standard.set(false,forKey: "dbSelected")
        UserDefaults.standard.set("",forKey: "dbToken")
        UserDefaults.standard.set("",forKey: "businessFile")
    }
    
    @IBAction func goBack(){
        dismiss(animated: true)
    }
    
    @objc func viewWebsite(sender: UITapGestureRecognizer){
        if let url = URL(string: "https://know.olivs.app/time-attendance/mobile-app/") {
            UIApplication.shared.open(url)
        }
    }



    
}
