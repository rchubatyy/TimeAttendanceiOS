//
//  Constants.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation
import UIKit
import Alamofire


let BASE_URL = "https://ontimeappservice1.olivs.cloud/api/" + getCurrentLanguage()
let BASE_URL_V1 = BASE_URL + "/app/"
let BASE_URL_V2 = BASE_URL + "/ontimev2/"


let INIT_USER_AUTHENTIFICATION = BASE_URL_V2 + "init-user-authentification"
let GET_USER_BUSINESS_FILES_LIST = BASE_URL_V2 + "get-user-business-files-list"
let GET_COMPANY_INFORMATION = BASE_URL_V1 + "get-company-information"
let GET_USER_INFO = BASE_URL_V2 + "get-user-info"
let REGISTER_USER_ACTIVITY = BASE_URL_V2 + "register-user-activity-v2"

let FORGOT_PASSWORD_LINK = "https://s1.olivs.app/0/en-au/olivs/forgot-user-login-password"
let REGISTER_LINK = "https://olivs.app/ontime"
let HELP_WEBSITE = "https://help.olivs.app/ontime/"
let PRIVACY_POLICY_WEBSITE = "https://olivs.app/privacy-policy/"

private var apiKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "Olivs-Info", ofType: "plist") else {
      fatalError("Couldn't find file")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "Api-Key") as? String else {
      fatalError("Couldn't find key")
    }
    return value
  }
}

private var olivsRootPassword: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "Olivs-Info", ofType: "plist") else {
      fatalError("Couldn't find file")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "Olivs-Root-Password") as? String else {
      fatalError("Couldn't find key")
    }
    return value
  }
}

let PUBLIC_IP = "192.168.0.1"

var requestHeaders: [String:String] = ["Api-Key" : apiKey,
                        "Olivs-Root-Password" : olivsRootPassword,
                        "Olivs-API-Real-IP" : "192.168.0.1",
                        "Olivs-API-Computer-Name" : "BTMSOFTPC"]

let HEADERS = HTTPHeaders(requestHeaders)

let BUTTON_COLOR = #colorLiteral(red: 0.6783741117, green: 0.7995368242, blue: 0.2318098545, alpha: 1)
let BACKGROUND_COLOR = #colorLiteral(red: 0.2760762572, green: 0.3335207105, blue: 0.4444260597, alpha: 1)
