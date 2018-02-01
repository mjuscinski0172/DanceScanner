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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func whenConfirmButtonPressed(_ sender: UIButton) {

        if guestNameTextField.text! == "" || guestSchoolTextField.text! == "" || parentPhoneNumberTextField.text! == ""{
            let alert = UIAlertController(title: "Error", message: "It appears that you have missed some information about this student. Please look back and type in ALL the information", preferredStyle: .alert)
            let alertAccept = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(alertAccept)
        }
        else {
            var guestName = guestNameTextField.text
            var guestSchool = guestSchoolTextField.text
            var guestParentNumber = parentPhoneNumberTextField.text
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
            
            
            self.database.save(place) { (record, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                print(1)
                
                print(3)
            }
            print(4)
            
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
     
}
