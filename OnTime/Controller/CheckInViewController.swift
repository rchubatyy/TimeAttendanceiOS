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

class CheckInViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var companyMessage: UILabel!
    @IBOutlet weak var areWeReadyMessage: UILabel!
    @IBOutlet var checkInButtons: [UIButton]!
    @IBOutlet weak var resultsMessage: UILabel!
    var isLocationRequested: Bool = false
    let locationManager = CLLocationManager()
    var lastLoc : CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        showCompanyInfo()
        setButtonsEnabled(false)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if (CheckInService.instance.reinitCheckInInfo()){
            showCompanyInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //print("View will disappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("View did appear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("View did disappear")
    }
    
    override func viewWillLayoutSubviews() {
        //print("View will layout subviews")
    }
    
    override func viewDidLayoutSubviews() {
        //print("View did layout subviews")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        setButtonsEnabled(false)
        areWeReadyMessage.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        areWeReadyMessage.text = "Location is not available."
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isLocationRequested{
        showCanGetLocation()
        }
        isLocationRequested = true
        lastLoc = locationManager.location?.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways || status != .authorizedWhenInUse{
        showCannotGetLocation()
        }
        else{
        showCanGetLocation()
        }
        
    }
    

    @IBAction func buttonPressed (sender: UIButton){
        resultsMessage.text = "Uploading activity..."
        locationManager.startUpdatingLocation()
        let states: [Int: ActivityType] = [1: .CHECKIN, 2: .BREAKSTART, 3: .BREAKEND, 4: .CHECKOUT]
        setButtonsEnabled(false)
        CheckInService.instance.registerUserActivity(loc: lastLoc!, activityType: states[sender.tag ]!){(success, message) in
            
                SQLHelper.instance.insert(record: CheckInService.instance.checkInInfo)

            if !success {
                let alertController = UIAlertController(title: "Could not connect to service, but your activity is saved on your phone. You need to sync the activity later.", message:
                        "To do this, go to\nSettings > Sync all activity.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
                self.resultsMessage.text = "Failed to upload data."
            }
            else{
                self.resultsMessage.text = message
               
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.setButtonsEnabled(true)
            }
 
        }
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
        setButtonsEnabled(false)
        areWeReadyMessage.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        areWeReadyMessage.text = "Sorry, you can't check in because location is not available."
    }
    
    private func showCanGetLocation(){
        setButtonsEnabled(true)
        areWeReadyMessage.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        areWeReadyMessage.text = "Location is available."
    }
    
    
    private func showCompanyInfo(){
        self.companyMessage.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.companyMessage.text = "Loading info..."
    FilesListService.instance.getCompanyInformation(){ (success, message) in
        if !success{
            self.companyMessage.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        self.companyMessage.text = message
    }
    }
    

}
