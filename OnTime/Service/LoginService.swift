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

    public var loggedIn: Bool{
        get{
            return UserDefaults.standard.bool(forKey: "loggedIn")
        }
    }
public private(set) var userToken: String


    private init(){
        //loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        userToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    func login(withEmail email: String, andPassword password: String, completion: @escaping (Bool, String) -> ()){
        let body = ["LoginEmail" : email, "LoginPassword": password]
        AF.request(INIT_USER_AUTHENTIFICATION, method: .post, parameters: body, headers: HEADERS).responseJSON{response in
            if (response.response?.statusCode == 200){
                let data = JSON(response.value!)
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    let userToken = data["usrUserToken"].string ?? ""
                    UserDefaults.standard.set(userToken, forKey: "userToken")
                    UserDefaults.standard.set("\(data["usrFirstName"]) \(data["usrLastName"])",forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    self.userToken = userToken
                    completion(true, "\(data["usrFirstName"]) \(data["usrLastName"])" )
            }
            else {
                if (!email.isEmpty && password.isEmpty){
                    completion(false, "Please assign User Password!")
                }
                else {
                    guard let data = response.value else{
                        completion(false, "Failed to log in")
                        return
                    }
                    completion(false, data as! String)
                }
            }
        }
    }
    
    func logout(){        
            UserDefaults.standard.set(false,forKey: "loggedIn")
            UserDefaults.standard.set("",forKey: "userToken")
            UserDefaults.standard.set("",forKey: "name")
            UserDefaults.standard.set("",forKey: "email")
    }
    
    
}
