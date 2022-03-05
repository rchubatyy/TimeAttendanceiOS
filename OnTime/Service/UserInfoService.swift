//
//  UserInfoService.swift
//  OnTime
//
//  Created by Roman Chubatyy on 18.07.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserInfoService{
    
    static let instance = UserInfoService()
    
    public var rosterReminderData: String?{
        get{
            return UserDefaults.standard.string(forKey: "rosterReminderData")
        }
    }
    public var lastEvent: ActivityType?{
        get{
            return ActivityType(rawValue: UserDefaults.standard.string(forKey: "lastEvent") ?? "CHECKOUT")
        }
    }
    var questionIds: [ActivityType: Int]{
        get{
            return [.CHECKIN : UserDefaults.standard.integer(forKey: "checkInQid"),
                    .BREAKSTART : UserDefaults.standard.integer(forKey: "breakStartQid"),
                    .BREAKEND : UserDefaults.standard.integer(forKey: "breakEndQid"),
                    .CHECKOUT : UserDefaults.standard.integer(forKey: "checkOutQid")
            ]
        }
    }
    var questions: [ActivityType: String?]{
        get{
            return [.CHECKIN : UserDefaults.standard.string(forKey: "checkInQ"),
                    .BREAKSTART : UserDefaults.standard.string(forKey: "breakStartQ"),
                    .BREAKEND : UserDefaults.standard.string(forKey: "breakEndQ"),
                    .CHECKOUT : UserDefaults.standard.string(forKey: "checkOutQ")
            ]
        }
    }
    var surveyURL: String?{
        get{
            return UserDefaults.standard.string(forKey: "surveyURL")
        }
    }

    func getUserInfo(completion: @escaping (Bool) -> ()){
        var request = URLRequest(url: URL(string:GET_USER_INFO)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers = HEADERS
        request.timeoutInterval = 5
        var body: [String: Any] = [:]
        body["UserToken"] = FilesListService.instance.getUserToken()
        body["DBToken"] = FilesListService.instance.getDBToken()
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        AF.request(request as URLRequestConvertible).responseJSON{response in
            if (response.response?.statusCode == 200){
                if let value = response.value{
                let data = JSON(value)
                    if data["rsrRosterReminderData"].exists(){
                if let rosterReminderDateTime = data["rsrRosterReminderData"]["rsrReminderDateTime"].string{
                        UserDefaults.standard.set(rosterReminderDateTime, forKey: "rosterReminderData")}
                        else{
                            UserDefaults.standard.set("null", forKey: "rosterReminderData")
                        }
                    }
                    else{
                        UserDefaults.standard.set("null", forKey: "rosterReminderData")
                    }
                if let lastEvent = data["usrLastEvnt_otlCheckType"].string{
                    UserDefaults.standard.set(lastEvent, forKey: "lastEvent")}
                if let checkInQid = data["qckQuestionCheckIn"]["QuestionID"].int{
                    UserDefaults.standard.set(checkInQid, forKey: "checkInQid")}
                if let checkInQ = data["qckQuestionCheckIn"]["QuestionText"].string{
                    UserDefaults.standard.set(checkInQ, forKey: "checkInQ")}
                if let breakStartQid = data["qckQuestionBreakStart"]["QuestionID"].int{
                    UserDefaults.standard.set(breakStartQid, forKey: "breakStartQid")}
                if let breakStartQ = data["qckQuestionBreakStart"]["QuestionText"].string{
                    UserDefaults.standard.set(breakStartQ, forKey: "breakStartQ")}
                if let breakEndQid = data["qckQuestionBreakEnd"]["QuestionID"].int{
                    UserDefaults.standard.set(breakEndQid, forKey: "breakEndQid")}
                if let breakEndQ = data["qckQuestionBreakEnd"]["QuestionText"].string{
                    UserDefaults.standard.set(breakEndQ, forKey: "breakEndQ")}
                if let checkOutQid = data["qckQuestionCheckOut"]["QuestionID"].int{
                    UserDefaults.standard.set(checkOutQid, forKey: "checkOutQid")}
                if let checkOutQ = data["qckQuestionCheckOut"]["QuestionText"].string{
                    UserDefaults.standard.set(checkOutQ, forKey: "checkOutQ")}
                if let surveyURL = data["SurveyURL"].string{
                    UserDefaults.standard.set(surveyURL, forKey: "surveyURL")}
                completion(true)
                }
                else{
                    completion(false)
                }
            }
            else{
                completion(false)
            }
        }
        
    }
    
    func removeUserInfo(){
        let keys = ["rosterReminderData","lastEvent", "surveyURL",
                    "checkInQid", "checkInQ", "breakStartQid", "breakStartQ", "breakEndQid", "breakEndQ", "checkOutQid", "checkOutQ"]
        for key in keys{
        UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
}
