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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var database = CKContainer.default().publicCloudDatabase
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
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                areYouPositive.addAction(OKAction)
                areYouPositive.addAction(cancelAction2)
                self.present(areYouPositive, animated: true, completion: nil)
            }
            else {
                let youDunGoofedAlert = UIAlertController(title: "Password Incorrect", message: "The password you entered was incorrect.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                youDunGoofedAlert.addAction(OKAction)
                self.present(youDunGoofedAlert, animated: true, completion: nil)
            }
        }
        passwordAlert.addAction(cancelAction)
        passwordAlert.addAction(confirmAction)
        present(passwordAlert, animated: true, completion: nil)
    }
    
}

