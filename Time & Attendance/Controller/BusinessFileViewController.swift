//
//  BusinessFileViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 Business Tax & Money House. All rights reserved.
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
        if UserDefaults.standard.bool(forKey: "dbSelected"){
            toCheckInScreen()
        }
        okButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        okButton.isEnabled = false
        fileList.delegate = self
        fileList.dataSource = self
        fileList.register(UITableViewCell.self, forCellReuseIdentifier: "file")
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        fileList.addSubview(refreshControl)
        /*if UserDefaults.standard.bool(forKey: "dbSelected"){
            toCheckInScreen()
        }*/
        //else{
        refresh(self)
        //}
        // Do any additional setup after loading the view.
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.businessFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath)
        cell.textLabel?.text = self.service.businessFiles[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.okButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
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
        toCheckInScreen()
    }
    
    func toCheckInScreen(){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckInVC") as! CheckInViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    
    @objc func refresh(_ sender: Any) {
        FilesListService.instance.getBusinessFilesList(){(success, error) in
            if success{
                self.fileList.reloadData()
            }
            else{
                if UserDefaults.standard.bool(forKey: "dbSelected"){
                    self.toCheckInScreen()
                }
                else {
                //self.navigationController?.popViewController(animated: false)
                }
            }

            self.refreshControl.endRefreshing()
        }

    }
      

}