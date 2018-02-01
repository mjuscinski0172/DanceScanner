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
        }
    }
}
