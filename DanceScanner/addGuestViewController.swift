//
//  addGuestViewController.swift
//  DanceScanner
//
//  Created by Michal Juscinski on 1/23/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class addGuestViewController: UIViewController {
    
    @IBOutlet weak var guestNameTextField: UITextField!
    @IBOutlet weak var guestSchoolTextField: UITextField!
    @IBOutlet weak var parentPhoneNumberTextField: UITextField!
    var database = CKContainer.default().publicCloudDatabase
    var studentDictionary: NSDictionary!
    var altId: String!
    var selectedStudent: Student!
    var isProm: Bool!
    
    @IBOutlet weak var studentFoodTitleLabel: UILabel!
    @IBOutlet weak var guestFoodTitleLabel: UILabel!
    @IBOutlet weak var studentFoodControl: UISegmentedControl!
    @IBOutlet weak var guestFoodControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isProm == true {
            studentFoodTitleLabel.alpha = 1
            studentFoodControl.alpha = 1
            studentFoodControl.isEnabled = true
            guestFoodTitleLabel.alpha = 1
            guestFoodControl.alpha = 1
            guestFoodControl.isEnabled = true
        }
        else {
            studentFoodTitleLabel.alpha = 0
            studentFoodControl.alpha = 0
            studentFoodControl.isEnabled = false
            guestFoodTitleLabel.alpha = 0
            guestFoodControl.alpha = 0
            guestFoodControl.isEnabled = false
        }
    }
    
    @IBAction func whenConfirmButtonPressed(_ sender: UIButton) {
        
        if guestNameTextField.text! == "" || guestSchoolTextField.text! == "" || parentPhoneNumberTextField.text! == ""{
            let alert = UIAlertController(title: "Error", message: "It appears that you have missed some information about this student. Please look back and type in ALL the information", preferredStyle: .alert)
            let alertAccept = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(alertAccept)
            present(alert, animated: true, completion: nil)
        }
        else {
            var studentFoodChoice = 0
            var guestFoodChoice = 0
            if isProm == true {
                studentFoodChoice = studentFoodControl.selectedSegmentIndex + 1
                guestFoodChoice = guestFoodControl.selectedSegmentIndex + 1
            }
            let guestName = guestNameTextField.text
            let guestSchool = guestSchoolTextField.text
            let guestParentNumber = parentPhoneNumberTextField.text
            if selectedStudent == nil {
//                let studentDictionary = self.selectedStudentArray.firstObject as! NSDictionary
                let firstName = self.studentDictionary.object(forKey: "FIRST") as! NSString
                let lastName = self.studentDictionary.object(forKey: "LAST") as! NSString
                let ID = self.studentDictionary.object(forKey: "ID") as! NSInteger
                let parentFirst = self.studentDictionary.object(forKey: "GRDFIRST") as! NSString
                let parentLast = self.studentDictionary.object(forKey: "GRDLAST") as! NSString
                let parentCell = self.studentDictionary.object(forKey: "GRDCELL") as! NSString
                let parentHouseHold = self.studentDictionary.object(forKey: "GRDHHOLD") as! NSString
                
                let place = CKRecord(recordType: "Students")
                place.setObject(firstName as CKRecordValue, forKey: "firstName")
                place.setObject(lastName as CKRecordValue, forKey: "lastName")
                place.setObject(String(ID) as CKRecordValue, forKey: "idNumber")
                place.setObject(String(altId) as CKRecordValue, forKey: "altIDNumber")
                place.setObject((String(parentFirst) + " " + String(parentLast)) as CKRecordValue, forKey: "studentParentName")
                place.setObject(String(parentHouseHold) as CKRecordValue, forKey: "studentParentPhone")
                place.setObject(String(parentCell) as CKRecordValue, forKey: "studentParentCell")
                place.setObject("Purchased" as CKRecordValue, forKey: "checkedInOrOut")
                place.setObject("" as CKRecordValue, forKey: "checkInTime")
                place.setObject("" as CKRecordValue, forKey: "checkOutTime")
                place.setObject(guestName! as CKRecordValue, forKey: "guestName")
                place.setObject(guestSchool! as CKRecordValue, forKey: "guestSchool")
                place.setObject(guestParentNumber! as CKRecordValue, forKey: "guestParentPhone")
                place.setObject("Purchased" as CKRecordValue, forKey: "guestCheckIn")
                place.setObject("\(studentFoodChoice)" as CKRecordValue, forKey: "foodChoice")
                place.setObject("\(guestFoodChoice)" as CKRecordValue, forKey: "guestFoodChoice")
                
                self.database.save(place) { (record, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
            else {
                selectedStudent.guestName = guestName!
                selectedStudent.guestSchool = guestSchool!
                selectedStudent.guestParentPhone = guestParentNumber!
                
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "Students", predicate: predicate)
                database.perform(query, inZoneWith: nil) { (records, error) in
                    for student in records! {
                        let firstName = student.object(forKey: "firstName") as! String
                        if firstName == self.selectedStudent.firstName {
                            student.setObject(guestName! as CKRecordValue, forKey: "guestName")
                            student.setObject(guestSchool! as CKRecordValue, forKey: "guestSchool")
                            student.setObject(guestParentNumber! as CKRecordValue, forKey: "guestParentPhone")
                            student.setObject("Purchased" as CKRecordValue, forKey: "guestCheckIn")
                            student.setObject("\(studentFoodChoice)" as CKRecordValue, forKey: "foodChoice")
                            student.setObject("\(guestFoodChoice)" as CKRecordValue, forKey: "guestFoodChoice")
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
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
