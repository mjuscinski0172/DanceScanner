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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func whenConfirmButtonPressed(_ sender: UIButton) {

        
        if guestNameTextField.text! == "" || guestSchoolTextField.text! == "" || parentPhoneNumberTextField.text! == ""{
            let alert = UIAlertController(title: "Error", message: "It appears that you have missed some information about this student. Please look back and type in ALL the information", preferredStyle: .alert)
            let alertAccept = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(alertAccept)
        }
        else{
            var guestName = guestNameTextField.text
            var guestSchool = guestSchoolTextField.text
            var guestParentNumber = parentPhoneNumberTextField.text
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
