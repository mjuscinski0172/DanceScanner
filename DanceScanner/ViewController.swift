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
    var studentArray = [CKRecord]()
    var database = CKContainer.default().publicCloudDatabase

    @IBOutlet weak var homecomingOrPromSC: UISegmentedControl!
    @IBOutlet weak var deleteAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        self.view.insertSubview(blurEffectView, at: 0)
        
        self.internetTest()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
    }

    @IBAction func deleteAllButton(_ sender: UIButton) {
        //Creates an alert for the user to input the password before deleting all students
        let passwordAlert = UIAlertController(title: "Delete all students?", message: "If you would like to delete all students from the database, please insert your password", preferredStyle: .alert)
        passwordAlert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
            //Check if password is correct
            let passwordTextField = passwordAlert.textFields![0]
            if passwordTextField.text == self.resetAllPassword {
                self.createConfirmationAlert(goodOrBad: true)
            }
            else {
                self.createConfirmationAlert(goodOrBad: false)
            }
        }
        //Adds all buttons and presents alert on which password is inputted
        passwordAlert.addAction(cancelAction)
        passwordAlert.addAction(confirmAction)
        present(passwordAlert, animated: true, completion: nil)
    }
    
    func createConfirmationAlert (goodOrBad: Bool){
        if goodOrBad ==  true {
            //Double-checks with user
            let areYouPositive = UIAlertController(title: "Are you sure?", message: "All student records will be deleted", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.createStudentArray()
                //Displays an alert to give user confirmation that all students have been deleted
                let thanks = UIAlertController(title: "All student records have been deleted", message: "", preferredStyle: .alert)
                let thanksButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
                thanks.addAction(thanksButton)
                self.present(thanks, animated: true, completion: nil)
            })
            let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //Adds all buttons and presents alert to double-check
            areYouPositive.addAction(OKAction)
            areYouPositive.addAction(cancelAction2)
            self.present(areYouPositive, animated: true, completion: nil)
        }
        else {
            //If password is incorrect, tell the user
            let youDunGoofedAlert = UIAlertController(title: "Password Incorrect", message: "The password you entered was incorrect.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: { (action) in
                self.deleteAllButton(self.deleteAllButton)
            })
            //Adds all buttons and presents alert about incorrect password
            youDunGoofedAlert.addAction(OKAction)
            youDunGoofedAlert.addAction(tryAgain)
            self.present(youDunGoofedAlert, animated: true, completion: nil)
        }
        
    }
    
    func internetTest() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "JSONurl", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if records?.count == 0 {
                //If we cannot pull the JSON URL from CloudKit, there is probably no internet so tell the user
                let alert = UIAlertController(title: "Error: No Internet Connection", message: "Please connect to the Internet and try again", preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.internetTest()
                })
                alert.addAction(retryAction)
                self.present(alert, animated: true, completion: nil)
            }
            else if error != nil{
                //Creates an alert to inform the user of the error if there is one
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.internetTest()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToPurchase" {
            let nvc = segue.destination as! PurchaseScannerViewController
            print(homecomingOrPromSC.selectedSegmentIndex)
            if homecomingOrPromSC.selectedSegmentIndex == 1 {
                nvc.isProm = true
            }
            else {
                nvc.isProm = false
            }
        }
        else if segue.identifier == "mainToList" {
            let nvc = segue.destination as! ListViewController
            if homecomingOrPromSC.selectedSegmentIndex == 1 {
                nvc.isProm = true
            }
            else {
                nvc.isProm = false
            }
        }
        else if segue.identifier == "mainToCheck" {
            let nvc = segue.destination as! checkViewController
            if homecomingOrPromSC.selectedSegmentIndex == 1 {
                nvc.isProm = true
            }
            else {
                nvc.isProm = false
            }
        }
    }
    
    func createStudentArray() {
        //Clears local studentArray and queries CloudKit
        studentArray.removeAll()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            //Fills studentArray with all records
            for student in records! {
                self.studentArray.append(student)
            }
            //Goes through studentArray and deletes each student
            DispatchQueue.main.async {
                for student in self.studentArray {
                    print("Ka-Chang")
                    self.database.delete(withRecordID: student.recordID, completionHandler: { (id, error) in
                        //Displays an alert if there is an error
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

