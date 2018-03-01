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
    var selectedStudentArray: NSArray!
    var altId: String!
    var selectedStudent: Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent

    }
    
    @IBAction func whenConfirmButtonPressed(_ sender: UIButton) {
        
        if guestNameTextField.text! == "" || guestSchoolTextField.text! == "" || parentPhoneNumberTextField.text! == ""{
            let alert = UIAlertController(title: "Error", message: "It appears that you have missed some information about this student. Please look back and type in ALL the information", preferredStyle: .alert)
            let alertAccept = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(alertAccept)
            present(alert, animated: true, completion: nil)
        }
        else {
            
            var guestName = guestNameTextField.text
            var guestSchool = guestSchoolTextField.text
            var guestParentNumber = parentPhoneNumberTextField.text
            if selectedStudent == nil {
                let studentDictionary = self.selectedStudentArray.firstObject as! NSDictionary
                let firstName = studentDictionary.object(forKey: "First") as! NSString
                let lastName = studentDictionary.object(forKey: "Last") as! NSString
                let ID = studentDictionary.object(forKey: "ID") as! NSInteger
                let place = CKRecord(recordType: "Students")
                place.setObject(firstName as CKRecordValue, forKey: "firstName")
                place.setObject(lastName as CKRecordValue, forKey: "lastName")
                place.setObject(String(ID) as CKRecordValue, forKey: "idNumber")
                place.setObject(String(altId) as CKRecordValue, forKey: "altIDNumber")
                place.setObject("Purchased" as CKRecordValue, forKey: "checkedInOrOut")
                place.setObject("" as CKRecordValue, forKey: "checkInTime")
                place.setObject("" as CKRecordValue, forKey: "checkOutTime")
                place.setObject(guestName as! CKRecordValue, forKey: "guestName")
                place.setObject(guestSchool as! CKRecordValue, forKey: "guestSchool")
                place.setObject(guestParentNumber as! CKRecordValue, forKey: "guestParentPhone")
                place.setObject("Present" as! CKRecordValue, forKey: "guestCheckIn")
                
                
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
                            student.setObject(guestName as! CKRecordValue, forKey: "guestName")
                            student.setObject(guestSchool as! CKRecordValue, forKey: "guestSchool")
                            student.setObject(guestParentNumber as! CKRecordValue, forKey: "guestParentPhone")
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
