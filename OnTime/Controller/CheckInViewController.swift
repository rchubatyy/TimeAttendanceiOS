//
//  CheckInViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 OlivsMatic Pty Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import UserNotifications

class CheckInViewController: UIViewController, CLLocationManagerDelegate, ChangeBusinessFileDelegate {
    
    
    @IBOutlet weak var companyMessage: UILabel!
    @IBOutlet weak var areWeReadyMessage: UILabel!
    @IBOutlet var checkInButtons: [UIButton]!
    @IBOutlet weak var resultsMessage: UILabel!
    let locationManager = CLLocationManager()
    var registering: Bool = false
    var locationAvailable: Bool = false
    var userInfoLoaded: Bool = false
    var state: ActivityType?
    var questionId: Int?
    var questionAnswer: String?
    let reachability = NetworkReachabilityManager()
    var infoShown: Bool!
    let notificationCenter = UNUserNotificationCenter.current()
    var alertMessage: DispatchWorkItem?
    
    let userInfoService = UserInfoService.instance
    

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.removeAllDeliveredNotifications()
        infoShown = false
        showCompanyInfo()
        setButtonsEnabled(false)
        reachability?.startListening{status in
            if !self.infoShown && (status == .reachable(.cellular) || status == .reachable(.ethernetOrWiFi)){
                self.showCompanyInfo()
            }
        }
        
        getUserInfo()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 1
        locationManager.activityType = .fitness
        locationManager.requestWhenInUseAuthorization()
        let notc = NotificationCenter.default
            notc.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
                        if granted == true && error == nil {
                            // We have permission!
                        }
                        else{
                            print("We need notifications!")
                        }
                }
        setAlertMessage()
        turnAlertOn()
    }
    
    @objc func appMovedToBackground(){
        alertMessage?.cancel()
    }
    
    @objc func appMovedToForeground(){
        turnAlertOn()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resultsMessage.text = "Failed to get location. \(error.localizedDescription)"
    }
    
    
    func locationManagerDidChangeAuthorization(){
        if (CLLocationManager.locationServicesEnabled()){
            showCanGetLocation()
        }
        else{
            showCannotGetLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        resultsMessage.text = "Uploading activity..."
        if let location = locations.last?.coordinate, let state = self.state, !registering{
            registering = true
            getUserInfo()
        CheckInService.instance.registerUserActivity(loc: location, activityType: state, questionId: questionId ?? 0, questionAnswer: questionAnswer ?? "X"){(success, message) in
                SQLHelper.instance.insert(record: CheckInService.instance.checkInInfo)
            if let reachable = self.reachability?.isReachable, reachable{
                SQLHelper.instance.sync(){(success, message) in }
            }
            if !success {
                let alertController = UIAlertController(title: "Could not connect to service, but your activity is saved on your phone. You need to sync the activity later.", message:
                        "To do this, go to\nSettings > Sync all activity.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            }
            self.resultsMessage.text = message
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.setButtonsEnabled(true)
                self.registering = false
            }
            self.turnAlertOn()
        }
        }        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways && status != .authorizedWhenInUse && status != .notDetermined{
        showCannotGetLocation()
        }
        else{
        showCanGetLocation()
        }
    }
    

    @IBAction func buttonPressed (sender: UIButton){
        alertMessage?.cancel()
        self.getUserInfo()
        let states: [Int: ActivityType] = [1: .CHECKIN, 2: .BREAKSTART, 3: .BREAKEND, 4: .CHECKOUT]
        self.state = states[sender.tag]!
       /* if let questionId = userInfoService.questionIds[state!], let q = userInfoService.questions[state!], let question = q, question != ""{
            self.questionId = questionId
            let alert = UIAlertController(title: question, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
                self.questionAnswer = "Y"
                self.startUploadingData()
            })
            alert.addAction(UIAlertAction(title: "No", style: .default) { action in
                self.questionAnswer = "N"
                self.startUploadingData()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.turnAlertOn()
        })
            self.present(alert, animated: true, completion: nil)
        }
        else{
            self.questionAnswer = "X"
            self.startUploadingData()
        }*/
        self.startUploadingData()
        
    }
    
    func setButtonsEnabled(_ status: Bool){
        for button in checkInButtons{
            button.backgroundColor = status ? (button.tag > 1 && button.tag < 4 ? #colorLiteral(red: 0.2760762572, green: 0.3335207105, blue: 0.4444260597, alpha: 1) : BUTTON_COLOR) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            if status && button.tag > 1 && button.tag < 4{
                button.layer.borderColor = BUTTON_COLOR.cgColor
                button.layer.borderWidth = 1
            }
            button.isEnabled = status
            button.isUserInteractionEnabled = status
        }
    }
    
    private func showCannotGetLocation(){
        locationAvailable = false
        setButtonsEnabled(false)
        areWeReadyMessage.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        areWeReadyMessage.text = "Location is not available."
    }
    
    private func showCanGetLocation(){
        locationAvailable = true
        if userInfoLoaded{
            setButtonsEnabled(true)
        }
        areWeReadyMessage.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if #available(iOS 14.0, *) {
            if (locationManager.accuracyAuthorization == CLAccuracyAuthorization.reducedAccuracy){
                areWeReadyMessage.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                areWeReadyMessage.text = "Location is not precise."
                locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location must be accurate")
            }
            else{
                areWeReadyMessage.text = "Location is available."
            }
        } else {
            areWeReadyMessage.text = "Location is available."
        }
    }
    
    
    private func showCompanyInfo(){
        self.companyMessage.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.companyMessage.text = "Loading information..."
    FilesListService.instance.getCompanyInformation(){ (success, message) in
        self.infoShown = success
        if !success{
             if !UserDefaults.standard.bool(forKey: "dbSelected"){
                 FilesListService.instance.removeFiles()
                 LoginService.instance.logout()
             }
             let alertController = UIAlertController(title: message?.string, message: nil, preferredStyle: .alert)
             alertController.addAction(UIAlertAction(title: "Return", style: .default, handler: {_ in
                 self.logout()
             }))
             self.present(alertController, animated: true)
             
        }
        else{
            if let isLater = message?.string.hasSuffix("later."){
                self.companyMessage.textColor = isLater ? #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            else{
                self.companyMessage.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            }
        }
        self.companyMessage.attributedText = message
    }
    }
    /**/
    
    @objc func refreshCompanyInfo() {
        setButtonsEnabled(false)
        showCompanyInfo()
        UserInfoService.instance.removeUserInfo()
        getUserInfo()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "TO_SETTINGS" {
                let nc = segue.destination as! DelegateNavigationController
                nc.changeDelegate = self
            }
        }
    
    func scheduleNotification(time: String?, after: ActivityType?){
        notificationCenter.removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        var toCheckIn: Bool = true
        if let after = after{
            toCheckIn = after == .CHECKOUT
        }
        content.title = "Time to check \(toCheckIn ? "in" : "out")"
        content.body = "Please do not forget to check \(toCheckIn ? "in" : "out")."
        content.sound = UNNotificationSound.default

        // Setup trigger time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        if let time = time, let date = dateFormatter.date(from: time){
        let calendar = Calendar.current
        let dateMatching = calendar.dateComponents([.day,.month,.year,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateMatching, repeats: false)

        // Create request
        let uniqueID = UUID().uuidString // Keep a record of this if necessary
        let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
        notificationCenter.add(request) // Add the notification request
        }
    }
    
    func startUploadingData(){
        resultsMessage.text = "Getting location..."
        locationManager.startUpdatingLocation()
        setButtonsEnabled(false)
    }
    
    func setAlertMessage(){
        alertMessage = DispatchWorkItem(block:{
            let alert = UIAlertController(title: "We haven’t seen you for a while.", message: "Click OK to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.setAlertMessage()
                self.turnAlertOn()
                self.showCompanyInfo()
                self.getUserInfo()
            })
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func turnAlertOn(){
        self.setAlertMessage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: alertMessage!)
    }
    
    func getUserInfo(){
        userInfoService.getUserInfo(){success in
            self.userInfoLoaded = true
            if self.locationAvailable, !self.registering{
                self.setButtonsEnabled(true)
            }
            if success{
                
                self.scheduleNotification(time: self.userInfoService.rosterReminderData,
                                      after: self.userInfoService.lastEvent)
            }
            else{
                //self.getUserInfo()
            }
        }
    }
    
    private func logout(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as!
                LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
        if #available(iOS 13.0, *) {
            let delegate = self.view.window?.windowScene?.delegate as? SceneDelegate

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
    
}
