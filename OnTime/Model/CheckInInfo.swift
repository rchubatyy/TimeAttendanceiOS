//
//  CheckInInfo.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import Foundation

class CheckInInfo{
    public var id: Int32 = 0
    public var usrToken: String
    public var dbToken: String
    public var time: String?
    public var lat: Double?
    public var lon: Double?
    public var site: String?
    public var checkInState: ActivityType?
    public var questionID: Int?
    public var questionAnswer: String?
    public var isLiveData: Bool? //true for LiveData, false for Sync
    public var resultId: String?
    
    
    
    init(){
        self.usrToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
        self.dbToken = UserDefaults.standard.string(forKey: "dbToken") ?? ""
    }
    
    
    
    func fillData(from body: [String: Any]){
        self.usrToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
        self.dbToken = UserDefaults.standard.string(forKey: "dbToken") ?? ""
        let time = body["PhDateTime"] as? String
        self.time = time?.replacingOccurrences(of: "/", with: "-")
        self.lat = body["GPSLat"] as? Double
        self.lon = body["GPSLon"] as? Double
        self.questionID = body["QuestionID"] as? Int
        self.questionAnswer = body["Answer"] as? String
    }
    

}

enum ActivityType: String{
    case CHECKIN
    case BREAKSTART
    case BREAKEND
    case CHECKOUT
}
