//
//  detailsViewController.swift
//  DanceScanner
//
//  Created by John Wilson on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//  stuff

import UIKit
import CloudKit

class detailsViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guestLabelAlphas()
        
        nameLabel.text = selectedStudent.firstName + " " + selectedStudent.lastName
        idLabel.text = selectedStudent.idNumber
        if selectedStudent.checkedInOrOut == "Purchased"{
            timeInLabel.alpha = 0
            timeOutLabel.alpha = 0
            timeInTitleLabel.alpha = 0
            timeOutTitleLabel.alpha = 0
            statusLabel.text = "Purchased Tickets"
            
        }
        else if selectedStudent.checkedInOrOut == "In" {
            timeInLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeInTitleLabel.alpha = 1
            timeOutTitleLabel.alpha = 0
            timeOutLabel.alpha = 0
            statusLabel.text = "In Dance"
        }
        else {
            timeInLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeOutLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeOutLabel.text = selectedStudent.checkOutTime
            statusLabel.text = "Checked Out"
        }
    }
    
    func guestLabelAlphas() {
        if selectedStudent.guestName == "" {
            lineLabel.alpha = 0
            guestInfoTitleLabel.alpha = 0
            guestNameTitleLabel.alpha = 0
            guestSchoolTitleLabel.alpha = 0
            guestParentPhoneTitleLabel.alpha = 0
            guestNameLabel.alpha = 0
            guestSchoolLabel.alpha = 0
            guestParentPhoneLabel.alpha = 0
            revoveGuestButton.alpha = 0
            revoveGuestButton.isEnabled = false
        }
        else {
            lineLabel.alpha = 1
            guestInfoTitleLabel.alpha = 1
            guestNameTitleLabel.alpha = 1
            guestSchoolTitleLabel.alpha = 1
            guestParentPhoneTitleLabel.alpha = 1
            guestNameLabel.alpha = 1
            guestSchoolLabel.alpha = 1
            guestParentPhoneLabel.alpha = 1
            revoveGuestButton.alpha = 1
            revoveGuestButton.isEnabled = true
            
            guestNameLabel.text = selectedStudent.guestName
            guestSchoolLabel.text = selectedStudent.guestSchool
            guestParentPhoneLabel.text = selectedStudent.guestParentPhone
        }
    }
    
    @IBAction func removeStudent(_ sender: UIButton) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            for student in records! {
                if student.object(forKey: "firstName") as! String == self.selectedStudent.firstName  {
                    self.database.delete(withRecordID: student.recordID, completionHandler: { (record, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            Thread.sleep(forTimeInterval: 1.0)

                            let alert = UIAlertController(title: "Student Deleted", message: nil, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.navigationController?.popViewController(animated: true)
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
//                            self.navigationController?.popViewController(animated: true)
                            print("Ba-zingas-Ka-chingas")
                        }
                    })
                }
            }
            DispatchQueue.main.async {
//                self.navigationController?.popViewController(animated: true)
                print("Ba-zingas-Ka-chingas-Ba-bangas")
            }
        }
    }
    
    @IBAction func removeGuest(_ sender: UIButton) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            for student in records! {
                if student.object(forKey: "guestName") as! String == self.selectedStudent.guestName  {
                    self.selectedStudent.guestName = ""
                    self.selectedStudent.guestSchool =  ""
                    self.selectedStudent.guestParentPhone = ""
                    student.setObject("" as CKRecordValue, forKey: "guestName")
                    student.setObject("" as CKRecordValue, forKey: "guestSchool")
                    student.setObject("" as CKRecordValue, forKey: "guestParentPhone")
                    self.database.save(student, completionHandler: { (record, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })


                }
            }
            DispatchQueue.main.async {
                print("Ba-zang")
                self.lineLabel.alpha = 0
                self.guestInfoTitleLabel.alpha = 0
                self.guestNameTitleLabel.alpha = 0
                self.guestSchoolTitleLabel.alpha = 0
                self.guestParentPhoneTitleLabel.alpha = 0
                self.guestNameLabel.alpha = 0
                self.guestSchoolLabel.alpha = 0
                self.guestParentPhoneLabel.alpha = 0
                self.revoveGuestButton.alpha = 0
                self.revoveGuestButton.isEnabled = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! addGuestViewController
        nvc.database = database
        nvc.selectedStudent = selectedStudent
//        detailsStudentArray.append(selectedStudent)
//        nvc.selectedStudentArray = detailsStudentArray as NSArray
    }
    
    
}
