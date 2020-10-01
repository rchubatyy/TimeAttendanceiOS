//
//  LoginService.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class LoginService{

static let instance = LoginService()

public private(set) var loggedIn: Bool
public private(set) var userToken: String


    private init(){
        loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        userToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    func login(withEmail email: String, andPassword password: String, completion: @escaping (Bool, String) -> ()){
        let body = ["Email" : email, "Password": password]

        AF.request(INIT_USER_AUTHENTIFICATION, method: .post, parameters: body).responseJSON{response in
            if (response.error == nil){
                let data = JSON(response.value!)
                switch(data["usrSuccess"]){
                case "Y":
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    let userToken = data["usrUserToken"].string ?? ""
                    UserDefaults.standard.set(userToken, forKey: "userToken")
                    UserDefaults.standard.set("\(data["usrFirstName"]) \(data["usrLastName"])",forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    self.loggedIn = true
                    self.userToken = userToken
                    completion(true, "\(data["usrFirstName"]) \(data["usrLastName"])" )
                default:
                    completion(false, data["usrErrorMessage"].string ?? "Incorrect email and/or password")
                }
            }
            else {
                if (!email.isEmpty && password.isEmpty){
                    completion(false, "Please assign User Password!")
                }
                else {
                completion(false, "Failed to log in")
                }
            }
        }
    }
    
    
}
