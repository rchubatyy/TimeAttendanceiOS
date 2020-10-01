//
//  SplashScreenViewController.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import UIKit
import CoreLocation

class SplashScreenViewController: UIViewController {


    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if !LoginService.instance.loggedIn{
            welcomeMessage.text = "Welcome!"
            getStartedButton.removeFromSuperview()
            logInButton.setTitle("Log In", for: .normal)
        }
        else{
            welcomeMessage.text = "Welcome back, \(FilesListService.instance.getName())"
        }
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
    }
    

    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.getStartedButton != nil{
                self.getStartedButton.removeFromSuperview()
        }
            self.logInButton.setTitle("Log In", for: .normal)
            self.welcomeMessage.text = "See you later!"
        }
    }
    
    

}
