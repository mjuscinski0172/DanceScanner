//
//  ViewController.swift
//  DanceScanner
//
//  Created by Michal Juscinski, Akhil Nair, Jimmy Rodriguez, and John Isaac Wilson on 12/4/17.
//  Copyright © 2017 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    var resetAllPassword = "57bw32Gc"
    var studentArray = [Student]()
    var database = CKContainer.default().publicCloudDatabase

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var database = CKContainer.default().publicCloudDatabase
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteAllButton(_ sender: UIButton) {
        let passwordAlert = UIAlertController(title: "Delete all students?", message: "If you would like to delete all students from the database, please insert your password", preferredStyle: .alert)
        passwordAlert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
            let passwordTextField = passwordAlert.textFields![0]
            if passwordTextField.text == self.resetAllPassword {
                let areYouPositive = UIAlertController(title: "Are you sure?", message: "You cannot go back from here.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.createStudentArray()
                })
                let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                areYouPositive.addAction(OKAction)
                areYouPositive.addAction(cancelAction2)
                self.present(areYouPositive, animated: true, completion: nil)
            }
            else {
                let youDunGoofedAlert = UIAlertController(title: "Password Incorrect", message: "The password you entered was incorrect.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                let tryAgain = UIAlertAction(title: "Try Again?", style: .default, handler: nil)
                youDunGoofedAlert.addAction(OKAction)
                youDunGoofedAlert.addAction(tryAgain)

                self.present(youDunGoofedAlert, animated: true, completion: nil)
            }
        }
        passwordAlert.addAction(cancelAction)
        passwordAlert.addAction(confirmAction)
        present(passwordAlert, animated: true, completion: nil)
    }
    
    func createStudentArray() {
        studentArray.removeAll()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            for student in records! {
                let firstName = student.object(forKey: "firstName") as! String
                let lastName = student.object(forKey: "lastName") as! String
                let altIDNumber = student.object(forKey: "altIDNumber") as! String
                let idNumber = student.object(forKey: "idNumber") as! String
                let checkedInOrOut = student.object(forKey: "checkedInOrOut") as! String
                let checkInTime = student.object(forKey: "checkInTime") as! String
                let checkOutTime = student.object(forKey: "checkOutTime") as! String
                let guestName = student.object(forKey: "guestName") as! String
                let guestSchool = student.object(forKey: "guestSchool") as! String
                let guestParentPhone = student.object(forKey: "guestParentPhone") as! String
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime, guestName: guestName, guestSchool: guestSchool, guestParentPhone: guestParentPhone)
                self.studentArray.append(newStudent)
            }
            DispatchQueue.main.async {
                print("Nothing")
            }
        }
    }
    
    
}

