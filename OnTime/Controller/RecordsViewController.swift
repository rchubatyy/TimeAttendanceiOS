//
//  RecordsViewController.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 30/7/20.
//  Copyright © 2020 OlivsMatic Pty Ltd. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var daysField: UITextField!
    @IBOutlet weak var recordsTable: UITableView!

    let picker = UIPickerView()

    var options: [Int] = []
    
    var records: [CheckInInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...99{
            options.append(i)
        }
        setupPicker()
        recordsTable.delegate = self
        recordsTable.dataSource = self
        recordsTable.tableFooterView = UIView()
        recordsTable.register(UITableViewCell.self, forCellReuseIdentifier: "record")
        recordsTable.backgroundColor = BACKGROUND_COLOR
    }
    
    override func viewWillAppear(_ animated: Bool) {
        records = SQLHelper.instance.getRecords(unsyncedOnly: false)
        recordsTable.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(options[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        daysField.text = "\(options[row])"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = BACKGROUND_COLOR
        if self.records[indexPath.row].resultId == ""{
            cell.textLabel?.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        }
        else{
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        cell.textLabel?.font = cell.textLabel?.font.withSize(18)
        cell.textLabel?.text = "\(self.records[indexPath.row].time!) | \(self.records[indexPath.row].checkInState!.rawValue)"
        return cell
    }

    
    
    func setupPicker(){
        picker.delegate = self
        picker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.done, target: self, action: #selector(numberSelected))

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        daysField.inputView = picker
        daysField.inputAccessoryView = toolBar
    }
    
    @objc func numberSelected(){
        daysField.resignFirstResponder()
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        SQLHelper.instance.clearRecords(olderThanDays: Int(daysField.text!)!){success in
            if success{
                records = SQLHelper.instance.getRecords(unsyncedOnly: false)
                recordsTable.reloadData()
            }
        }
    }
    
    @IBAction func goBack(){
        dismiss(animated: true)
    }
    

    @IBAction func syncPressed(_ sender: Any) {
        SQLHelper.instance.sync(){success, message in
            let alertController = UIAlertController(title: "Sync", message:
                    message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            if success{
            self.records = SQLHelper.instance.getRecords(unsyncedOnly: false)
            self.recordsTable.reloadData()
            }
            self.present(alertController, animated: true)
        }
    }
    
    

}
