//
//  FilesListService.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 5/8/20.
//  Copyright © 2020 Business Tax & Money House. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FilesListService{
    static let instance = FilesListService()
    public private(set) var businessFiles: [BusinessFile] = []
    var dbSelected = UserDefaults.standard.bool(forKey: "dbSelected")
    var dbToken: String = UserDefaults.standard.string(forKey: "dbToken") ?? ""
    
    private init(){
    }
    
    func getBusinessFilesList(completion: @escaping (Bool, String)->()){
        let body = ["UserToken" : getUserToken()]
        AF.request(GET_USER_BUSINESS_FILES_LIST, method: .post, parameters: body).responseJSON{response in
            if (response.error == nil){
                let data = JSON(response.value!)
                switch(data["dbtSuccess"]){
                case "Y":
                    let results = data["dbtBusinessFiles"].arrayValue
                    for result in results{
                        let name = result["dbtBusinessName"].string!
                        let token = result["dbtDBToken"].string!
                        self.businessFiles = []
                        self.businessFiles.append(BusinessFile(name: name, token: token))
                    }
                    completion(true, "")
                default:
                    completion(false, data["dbtErrorMessage"].string ?? "Database error")
                }
            }
            else {
                completion(false, "Failed to retrive business files")
                }
            }
        }
    
    func getCompanyInformation(completion: @escaping (Bool, String)->()){
        let body = ["UserToken" : getUserToken(), "DBToken" : getDBToken()]
    AF.request(GET_COMPANY_INFORMATION, method: .post, parameters: body).responseJSON{response in
        if (response.error == nil){
            let data = JSON(response.value!)
            switch(data["cmpSuccess"]){
            case "Y":
                let companyInfoHTML = data["cmpInfoMessage"].string ?? "<p>No info yet.</p>"
                let companyInfo = companyInfoHTML.htmlToString
                completion(true, companyInfo)
            default:
                completion(false, data["cmpErrorMessage"].string ?? "Error")
            }
        }
        else {
            completion(false, "Failed to retrive business files")
            }
        }
    }
    
    func getUserToken() -> String{
        return UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    func getDBToken() -> String{
        return UserDefaults.standard.string(forKey: "dbToken") ?? ""
    }
    
    }

struct BusinessFile{
    public private(set) var name: String!
    public private(set) var token: String!
    
}

