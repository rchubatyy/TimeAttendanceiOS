//
//  FilesListService.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
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
        AF.request(GET_USER_BUSINESS_FILES_LIST, method: .post, parameters: body, headers: HEADERS).responseJSON{response in
            if (response.response?.statusCode == 200){
                let data = JSON(response.value!)
                    let results = data.arrayValue
                    self.businessFiles = []
                if results.isEmpty {
                    completion(false, "There are no business files associated to this user.")
                    return
                }
                    for result in results{
                        let name = result["xxbBusinessName"].string!
                        let token = result["xxbDBToken"].string!
                        self.businessFiles.append(BusinessFile(name: name, token: token))
                    }
                    self.saveFiles()
                    completion(true, "")
            }
            else {
                guard let data = response.value else{
                completion(false, "Error loading business files.")
                    return
                }
                completion(false, data as! String)
                }
            }
        }
    
    func getCompanyInformation(completion: @escaping (Bool, NSAttributedString?)->()){
        let body = ["UserToken" : getUserToken(), "DBToken" : getDBToken()]
        AF.request(GET_COMPANY_INFORMATION, method: .post, parameters: body, headers: HEADERS).responseJSON{response in
        if (response.response?.statusCode == 200){
            let data = JSON(response.value!)
                let companyInfoHTML = data["InfoMessage"].string ?? "<p>No info yet.</p>"
                var styledHTML = """
                 <html>
                 <head>
                 <style>
                 body{
                    color: white;
                    font-family: Helvetica;
                    font-size: 21px;
                 }
                 </style>
                 </head>
                 <body>
                """ + companyInfoHTML
                 + """
                    </body>
                    </html>
                    """
                styledHTML = styledHTML.replacingOccurrences(of: "&lt;", with: "<")
                styledHTML = styledHTML.replacingOccurrences(of: "&gt;", with: ">")
            print (styledHTML)
            let companyInfo = styledHTML.htmlToAttributedString //.replacingOccurrences(of: "\n", with: "")
                completion(true, companyInfo)
        }
            else if (response.response?.statusCode == 500){
                if let data = response.value as? NSAttributedString?{
                    completion(false, data)
                }
                else if let data = response.value as? String{
                    completion(false, NSAttributedString(string:data))
                }
                else{
                    completion(false, NSAttributedString(string: "Failed to retrive company information."))
                }
            }
            else {
            self.retrieveSavedFiles()
            //guard let data = response.value else{
                completion(true, NSAttributedString(string: "Failed to retrive company information. Try it later."))
                //return
            //}
            /*if let data = data as? NSAttributedString?{
                completion(false, data)
            }
            else if let data = data as? String{
                completion(false, NSAttributedString(string:data))
            }
            else {
                completion(false, NSAttributedString(string: "Failed to retrive company information."))
            }*/
            }
        }
    }
    
    func getUserToken() -> String{
        return UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    func getDBToken() -> String{
        return UserDefaults.standard.string(forKey: "dbToken") ?? ""
    }
    
    func getName() -> String{
        return UserDefaults.standard.string(forKey: "name") ?? ""
    }
    
    func saveFiles(){
        var names: [String] = []
        var tokens: [String] = []
        for file in businessFiles{
            names.append(file.name ?? "No name")
            tokens.append(file.token ?? "")
        }
        UserDefaults.standard.set(names, forKey: "businessFileNames")
        UserDefaults.standard.set(tokens, forKey: "businessFileTokens")
    }
    
    func removeFiles(){
        UserDefaults.standard.set(false,forKey: "dbSelected")
        UserDefaults.standard.set("",forKey: "dbToken")
        UserDefaults.standard.set("",forKey: "businessFile")
    }
    
    func retrieveSavedFiles(){
        var files: [BusinessFile] = []
        let names = UserDefaults.standard.array(forKey: "businessFileNames") as? [String] ?? []
        let tokens = UserDefaults.standard.array(forKey: "businessFileTokens") as? [String] ?? []
        for i in 0..<names.count{
            let file = BusinessFile(name: names[i], token: tokens[i])
            files.append(file)
        }
        self.businessFiles = files
    }
    
    }

struct BusinessFile{
    public private(set) var name: String?
    public private(set) var token: String?
    
}


