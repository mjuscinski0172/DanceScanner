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
        var database = CKContainer.default().publicCloudDatabase
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func deleteAllButton(_ sender: UIButton) {
        
    }
    
}

