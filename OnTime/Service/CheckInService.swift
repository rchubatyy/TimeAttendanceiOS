//
//  CheckInService.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON


class CheckInService{
    static let instance = CheckInService()
    
    let checkInInfo = CheckInInfo()
    
    
    func registerUserActivity(loc : CLLocationCoordinate2D, activityType: ActivityType, completion: @escaping (Bool, String) -> ()){
        var request = URLRequest(url: URL(string: REGISTER_USER_ACTIVITY)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        var body: [String: Any] = [:]
        body["UserToken"] = FilesListService.instance.getUserToken()
        body["DBToken"] = FilesListService.instance.getDBToken()
        body["ActivityType"] = activityType.rawValue
        body["GPSLat"] = loc.latitude
        body["GPSLon"] = loc.longitude
        body["PhDateTime"] = getPhoneDate()
        body["isLiveDataOrSync"] = "L"
        body["OSVersion"] = getIOSVersion()
        body["PhoneModel"] = getIPhoneModel()
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        AF.request(request as URLRequestConvertible).responseJSON{response in
            let dict: [ActivityType : String] = [.CHECKIN : "Checked in", .BREAKSTART : "Started break",
                .BREAKEND : "Ended break", .CHECKOUT : "Checked out"]
            var result: String = ""
            self.checkInInfo.fillData(from: body)
            self.checkInInfo.checkInState = activityType
            self.checkInInfo.isLiveData = true
            if (response.error == nil){
                let data = JSON(response.value!)
                switch(data["acdSuccess"]){
                case "Y":
                    result += dict[activityType]!
                    let isSite = data["acdSiteID"].int8 ?? 0
                    let siteName = data["acdSiteName"].string!
                    result += isSite == 1 ? " at: \n\(siteName) " : ".\n\(siteName)"
                    self.checkInInfo.site = siteName
                    self.checkInInfo.resultId = data["acdID"].string ?? ""
                    completion(true, result)
                default:
                    result = data["acdErrorMessage"].string ?? "Error! Registration data was not saved!"
                    completion(false, result)
                }
            }
            else {
                result += "Could not connect to cloud. Activity saved on the phone. You need to Sync later."
                self.checkInInfo.resultId = ""
                completion(false, result)
                }
            }
    }
    
    func syncUserActivity(checkInInfo: CheckInInfo, completion: @escaping (Bool, String) -> ()){
        var body: [String: Any] = [:]
        body["UserToken"] = FilesListService.instance.getUserToken()
        body["DBToken"] = FilesListService.instance.getDBToken()
        body["ActivityType"] = checkInInfo.checkInState?.rawValue
        body["GPSLat"] = checkInInfo.lat
        body["GPSLon"] = checkInInfo.lon
        body["PhDateTime"] = checkInInfo.time?.replacingOccurrences(of: "-", with: "/")
        body["isLiveDataOrSync"] = "S"
        body["OSVersion"] = getIOSVersion()
        body["PhoneModel"] = getIPhoneModel()
        AF.request(REGISTER_USER_ACTIVITY, method: .post, parameters: body).responseJSON{response in
            if (response.error == nil){
                let data = JSON(response.value!)
                switch(data["acdSuccess"]){
                case "Y":
                let newResultId = data["acdID"].string ?? ""
                completion(true, newResultId)
                default:
                completion(false, data["acdErrorMessage"].string ?? "Error! Registration data was not saved!")
                }
            }
                else {
                completion(false, "")
            }
        }
    }
    
    func reinitCheckInInfo() -> Bool{
        let oldUsrToken = self.checkInInfo.usrToken
        let oldDbToken = self.checkInInfo.dbToken
        self.checkInInfo.usrToken = FilesListService.instance.getUserToken()
        self.checkInInfo.dbToken = FilesListService.instance.getDBToken()
        return (self.checkInInfo.usrToken != oldUsrToken || self.checkInInfo.dbToken != oldDbToken)
    }
}
