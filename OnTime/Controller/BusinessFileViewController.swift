//
//  BusinessFileViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 OlivsMatic Pty Ltd. All rights reserved.
//

import UIKit

class BusinessFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let service = FilesListService.instance
    private var fileName: String?
    private var refreshControl = UIRefreshControl()
    
    
    
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var okButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        okButton.isEnabled = false
        fileList.delegate = self
        fileList.dataSource = self
        fileList.tableFooterView = UIView()
        fileList.register(UITableViewCell.self, forCellReuseIdentifier: "file")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        fileList.addSubview(refreshControl)
        refresh(self)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.businessFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath)
        cell.backgroundColor = BACKGROUND_COLOR
        let backgroundView = UIView()
        backgroundView.backgroundColor = BUTTON_COLOR
        cell.selectedBackgroundView = backgroundView
        cell.textLabel?.font = cell.textLabel?.font.withSize(20)
        cell.textLabel?.text = self.service.businessFiles[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.okButton.backgroundColor = BUTTON_COLOR
        self.okButton.isEnabled = true
        self.service.dbToken = self.service.businessFiles[indexPath.row].token!
        self.fileName = self.service.businessFiles[indexPath.row].name!
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "dbSelected")
        UserDefaults.standard.set(self.service.dbToken, forKey: "dbToken")
        UserDefaults.standard.set(fileName, forKey: "businessFileName")
        let selectedItems = self.fileList.indexPathsForSelectedRows
        selectedItems?.forEach {
            self.fileList.deselectRow(at: $0, animated: false)
        }
        if let vc = self.navigationController?.viewControllers[0] as? SettingsViewController{
            if let _ = vc.presentingViewController as? RecordsViewController{
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
            else{
                dismiss(animated: true)
            }
        }
        else{
            toCheckInScreen()
        }
    }
    
    func toCheckInScreen(){
        performSegue(withIdentifier: "DB_SELECT", sender: nil)
        }
    
    @objc func refresh(_ sender: Any) {
        FilesListService.instance.getBusinessFilesList(){(success, error) in
            if success{
                self.fileList.reloadData()
                self.okButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.okButton.isEnabled = false
            }
            else{
                let alertController = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Return", style: .default, handler: {_ in
                    LoginService.instance.logout()
                    self.dismiss(animated: true)
                }))
                self.present(alertController, animated: true)
                if UserDefaults.standard.bool(forKey: "dbSelected"){
                    self.toCheckInScreen()
                }
            }

            self.refreshControl.endRefreshing()
        }

    }
    
      

}

