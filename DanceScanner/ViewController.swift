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
            if passwordTextField.text == resetAllPassword {
                
            }
            else {
                
            }
        }
        passwordAlert.addAction(cancelAction)
        passwordAlert.addAction(confirmAction)
        present(passwordAlert, animated: true, completion: nil)
    }
    
}

