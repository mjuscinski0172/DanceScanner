//
//  detailsViewController.swift
//  DanceScanner
//
//  Created by John Wilson on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class detailsViewController: UIViewController {

    var selectedStudent: Student!
    var database: CKDatabase!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timeInLabel: UILabel!
    @IBOutlet weak var timeOutLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeInTitleLabel: UILabel!
    @IBOutlet weak var timeOutTitleLabel: UILabel!
    @IBOutlet weak var statusTitlesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = selectedStudent.firstName + " " + selectedStudent.lastName
        idLabel.text = selectedStudent.idNumber
        if selectedStudent.checkedInOrOut == "Purchased"{
            timeInLabel.alpha = 0
            timeOutLabel.alpha = 0
            timeInTitleLabel.alpha = 0
            timeOutTitleLabel.alpha = 0
            statusLabel.text = "Purchased Tickets"
        }
        else if selectedStudent.checkedInOrOut == "In" {
            timeInLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeInTitleLabel.alpha = 1
            timeOutTitleLabel.alpha = 0
            timeOutLabel.alpha = 0
            statusLabel.text = "In Dance"
        }
        else {
            timeInLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeOutLabel.alpha = 1
            timeOutTitleLabel.alpha = 1
            timeInLabel.text = selectedStudent.checkInTime
            timeOutLabel.text = selectedStudent.checkOutTime
            statusLabel.text = "Checked Out"
        }
    }
}
