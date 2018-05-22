//
//  detailsViewController.swift
//  DanceScanner
//
//  Created by John Wilson on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//  stuff

import UIKit
import CloudKit
import SafariServices

class detailsViewController: UIViewController {
    
    var superSecretPassword = "57bw32Gc"
    
    var selectedStudent: Student!
    var database: CKDatabase!
    //    var detailsStudentArray = [Student]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timeInLabel: UILabel!
    @IBOutlet weak var timeOutLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeInTitleLabel: UILabel!
    @IBOutlet weak var timeOutTitleLabel: UILabel!
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var parentPhoneNumberLabel: UILabel!
    @IBOutlet weak var statusTitlesLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var guestInfoTitleLabel: UILabel!
    @IBOutlet weak var guestNameTitleLabel: UILabel!
    @IBOutlet weak var guestSchoolTitleLabel: UILabel!
    @IBOutlet weak var guestParentPhoneTitleLabel: UILabel!
    @IBOutlet weak var guestNameLabel: UILabel!
    @IBOutlet weak var guestSchoolLabel: UILabel!
    @IBOutlet weak var guestParentPhoneLabel: UILabel!
    @IBOutlet weak var revoveGuestButton: UIButton!
    @IBOutlet weak var foodChoiceTitleLabel: UILabel!
    @IBOutlet weak var foodChoiceLabel: UILabel!
    @IBOutlet weak var guestFoodChoiceTitleLabel: UILabel!
    @IBOutlet weak var guestFoodLabel: UILabel!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var parentNameTitleLabel: UILabel!
    @IBOutlet weak var parentPhoneTitleLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var icButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent

//        self.navigationItem.backBarButtonItem?.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Checks whether to make the guest section visible or not
        if selectedStudent.guestName == ""{
            if selectedStudent.guestFoodChoice == 0 {
                guestLabelAlphas(onOrOff: 0, food: false)
            }
            else {
                guestLabelAlphas(onOrOff: 0, food: true)
            }
        }
        else {
            if selectedStudent.guestFoodChoice == 0 {
                guestLabelAlphas(onOrOff: 1, food: false)
            }
            else {
                guestLabelAlphas(onOrOff: 1, food: true)
            }
        }
        //Sets text in the labels
        parentNameLabel.text = selectedStudent.studentParentName
        parentPhoneNumberLabel.text = "\(selectedStudent.studentParentPhone) (Household)\n\(selectedStudent.studentParentCell) (Cell)"
        if selectedStudent.studentParentCell == "" {
            parentPhoneNumberLabel.text = "\(selectedStudent.studentParentPhone) (Household)\nNo Cell Number"
        }
        else if selectedStudent.studentParentPhone == "" {
            parentPhoneNumberLabel.text = "No Household Number\n\(selectedStudent.studentParentCell) (Cell)"
        }
        else if selectedStudent.studentParentPhone == "" && selectedStudent.studentParentCell == "" {
            parentPhoneNumberLabel.text = "No Household Number\nNo Cell Number"
        }
        nameLabel.text = selectedStudent.firstName + " " + selectedStudent.lastName
        idLabel.text = selectedStudent.idNumber
        //Depending on the student's status, display different amounts of labels
        if selectedStudent.checkedInOrOut == "Purchased"{
            timeLabelAlphas(inness: 0, outness: 0)
            statusLabel.text = "Purchased Tickets"
        }
        else if selectedStudent.checkedInOrOut == "In" {
            timeLabelAlphas(inness: 1, outness: 0)
            statusLabel.text = "In Dance"
        }
        else {
            timeLabelAlphas(inness: 1, outness: 1)
            statusLabel.text = "Checked Out"
        }
        if selectedStudent.foodChoice == 0 {
            foodChoiceLabel.alpha = 0
            foodChoiceTitleLabel.alpha = 0
        }
        else {
            foodChoiceLabel.alpha = 1
            foodChoiceTitleLabel.alpha = 1
            foodChoiceLabel.text = "\(selectedStudent.foodChoice)"
        }
        //Sets colors based on HC or Prom
        if selectedStudent.foodChoice == 0 {
            chicken(buttonRed: 255, buttonGreen: 115, buttonBlue: 0, backRed: 92, backGreen: 60, backBlue: 31)
        }
        else {
            chicken(buttonRed: 81, buttonGreen: 88, buttonBlue: 117, backRed: 28, backGreen: 28, backBlue: 28)
        }
    }
    
    func timeLabelAlphas(inness: Int, outness: Int) {
        //If student has not checked in/out yet, hide the labels
        timeInLabel.alpha = CGFloat(inness)
        timeInLabel.text = selectedStudent.checkInTime
        timeInTitleLabel.alpha = CGFloat(inness)
        timeOutTitleLabel.alpha = CGFloat(outness)
        timeOutLabel.alpha = CGFloat(outness)
        timeOutLabel.text = selectedStudent.checkOutTime
    }
    
    func chicken(buttonRed: Double, buttonGreen: Double, buttonBlue: Double, backRed: Double, backGreen: Double, backBlue: Double) {
        let buttonColor = UIColor(red: CGFloat(buttonRed / 255.0), green: CGFloat(buttonGreen / 255.0), blue: CGFloat(buttonBlue / 255.0), alpha: 1)
        let backColor = UIColor(red: CGFloat(backRed / 255.0), green: CGFloat(backGreen / 255.0), blue: CGFloat(backBlue / 255.0), alpha: 1)
        icButton.backgroundColor = buttonColor
        nameTitleLabel.textColor = buttonColor
        idTitleLabel.textColor = buttonColor
        statusTitlesLabel.textColor = buttonColor
        parentNameTitleLabel.textColor = buttonColor
        parentPhoneTitleLabel.textColor = buttonColor
        timeInTitleLabel.textColor = buttonColor
        timeOutTitleLabel.textColor = buttonColor
        foodChoiceTitleLabel.textColor = buttonColor
        guestInfoTitleLabel.textColor = buttonColor
        guestNameTitleLabel.textColor = buttonColor
        guestSchoolTitleLabel.textColor = buttonColor
        guestParentPhoneTitleLabel.textColor = buttonColor
        guestFoodChoiceTitleLabel.textColor = buttonColor
        backgroundView.backgroundColor = backColor
        navigationController?.navigationBar.barTintColor = backColor
    }
    
    @IBAction func toInfiniteCampus(_ sender: Any) {
        //Sends the user to the infinite campus web site
        let svc = SFSafariViewController(url: URL(string: "https://ic.d214.org")!)
        self.present(svc, animated: true, completion: nil)
    }
    
    func guestLabelAlphas(onOrOff: Int, food: Bool) {
        //Depending on whether or not the student has a guest, show or hide all the things
        lineLabel.alpha = CGFloat(onOrOff)
        guestInfoTitleLabel.alpha = CGFloat(onOrOff)
        guestNameTitleLabel.alpha = CGFloat(onOrOff)
        guestSchoolTitleLabel.alpha = CGFloat(onOrOff)
        guestParentPhoneTitleLabel.alpha = CGFloat(onOrOff)
        guestNameLabel.alpha = CGFloat(onOrOff)
        guestSchoolLabel.alpha = CGFloat(onOrOff)
        guestParentPhoneLabel.alpha = CGFloat(onOrOff)
        revoveGuestButton.alpha = CGFloat(onOrOff)
        if food == true {
            guestFoodLabel.alpha = CGFloat(onOrOff)
            guestFoodChoiceTitleLabel.alpha = CGFloat(onOrOff)
        }
        else {
            guestFoodLabel.alpha = CGFloat(0)
            guestFoodChoiceTitleLabel.alpha = CGFloat(0)
        }
        if onOrOff == 0{
            revoveGuestButton.isEnabled = false
        }
        else if onOrOff == 1{
            revoveGuestButton.isEnabled = true
        }
        //Add guest info to labels
        guestNameLabel.text = selectedStudent.guestName
        guestSchoolLabel.text = selectedStudent.guestSchool
        guestParentPhoneLabel.text = selectedStudent.guestParentPhone
        guestFoodLabel.text = "\(selectedStudent.guestFoodChoice)"
    }
    
    @IBAction func removeStudent(_ sender: UIButton) {
        //Creates an alert to input password
        let alert = UIAlertController(title: "Delete student?", message: "Please input password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Insert Password"
        }
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let passTextField = alert.textFields![0]
            if passTextField.text == self.superSecretPassword {
                //If the password inputted is correct, query the database
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "Students", predicate: predicate)
                self.database.perform(query, inZoneWith: nil) { (records, error) in
                    for student in records! {
                        if student.object(forKey: "firstName") as! String == self.selectedStudent.firstName  {
                            //Delete the currently selected student from the database
                            self.database.delete(withRecordID: student.recordID, completionHandler: { (record, error) in
                                if error != nil {
                                    //Creates an alert to inform the user of the error if there is one
                                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                else {
                                    //Inform the user of the deletion
                                    Thread.sleep(forTimeInterval: 1.0)
                                    
                                    let alert = UIAlertController(title: "Student Deleted", message: nil, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
            else {
                //If password is incorrect, inform the user
                let failureAlert = UIAlertController(title: "Password Incorrect", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                failureAlert.addAction(okAction)
                self.present(failureAlert, animated: true, completion: nil)
            }
        }
        //Add all buttons and present alert
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func removeGuest(_ sender: UIButton) {
        //Creates an alert to input password
        let alert = UIAlertController(title: "Delete Guest?", message: "Please input password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Password"
        }
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let passTextField = alert.textFields![0]
            if passTextField.text == self.superSecretPassword {
                //If the password inputted is correct, query the database
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "Students", predicate: predicate)
                self.database.perform(query, inZoneWith: nil) { (records, error) in
                    for student in records! {
                        if student.object(forKey: "guestName") as! String == self.selectedStudent.guestName  {
                            //Clear all the guest information from the selected student
                            self.selectedStudent.guestName = ""
                            self.selectedStudent.guestSchool =  ""
                            self.selectedStudent.guestParentPhone = ""
                            student.setObject("" as CKRecordValue, forKey: "guestName")
                            student.setObject("" as CKRecordValue, forKey: "guestSchool")
                            student.setObject("" as CKRecordValue, forKey: "guestParentPhone")
                            self.database.save(student, completionHandler: { (record, error) in
                                if error != nil {
                                    //Inform the user of any error
                                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                    DispatchQueue.main.async {
                        //Disable all guest things
                        self.lineLabel.alpha = 0
                        self.guestInfoTitleLabel.alpha = 0
                        self.guestNameTitleLabel.alpha = 0
                        self.guestSchoolTitleLabel.alpha = 0
                        self.guestParentPhoneTitleLabel.alpha = 0
                        self.guestFoodChoiceTitleLabel.alpha = 0
                        self.guestNameLabel.alpha = 0
                        self.guestSchoolLabel.alpha = 0
                        self.guestParentPhoneLabel.alpha = 0
                        self.guestFoodLabel.alpha = 0
                        self.revoveGuestButton.alpha = 0
                        self.revoveGuestButton.isEnabled = false
                    }
                }
            }
            else {
                //If password is incorrect, inform the user
                let failureAlert = UIAlertController(title: "Password Incorrect", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                failureAlert.addAction(okAction)
                self.present(failureAlert, animated: true, completion: nil)
            }
        }
        //Add all buttons and present alert
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Sends current student to addGuestVC
        let nvc = segue.destination as! addGuestViewController
        nvc.database = database
        nvc.selectedStudent = selectedStudent
        if selectedStudent.foodChoice != 0{
            nvc.isProm = true
        }
        else {
            nvc.isProm = false
        }
    }
    
    
}
