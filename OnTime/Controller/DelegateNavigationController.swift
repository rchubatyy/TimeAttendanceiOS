//
//  DelegateNavigationController.swift
//  OnTime
//
//  Created by Roman Chubatyy on 30.01.2021.
//

import UIKit

class DelegateNavigationController: UINavigationController {
    
    var changeDelegate: ChangeBusinessFileDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /*if let delegate = self.changeDelegate{
            delegate.refreshCompanyInfo()
        }*/
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol ChangeBusinessFileDelegate {
    func refreshCompanyInfo()
}
