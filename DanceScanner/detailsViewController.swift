//
//  detailsViewController.swift
//  DanceScanner
//
//  Created by John Wilson on 1/12/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//  stuff

import UIKit
import CloudKit

class detailsViewController: UIViewController {

    var selectedStudent: Student!
    var database: CKDatabase!
//    var detailsStudentArray = [Student]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timeInLabel: UILabel!
    @IBOutlet weak var timeOutLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeInTitleLabel: UILabel!
    @IBOutlet weak var timeOutTitleLabel: UILabel!
    @IBOutlet weak var statusTitlesLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var guestInfoTitleLabel: UILabel!
    @IBOutlet weak var guestNameTitleLabel: UILabel!
    @IBOutlet weak var guestSchoolTitleLabel: UILabel!
    @IBOutlet weak var guestParentPhoneTitleLabel: UILabel!
    @IBOutlet weak var guestNameLabel: UILabel!
    @IBOutlet weak var guestSchoolLabel: UILabel!
    @IBOutlet weak var guestParentPhoneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guestLabelAlphas()
        
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
    
    func guestLabelAlphas() {
        if selectedStudent.guestName == "" {
            lineLabel.alpha = 0
            guestInfoTitleLabel.alpha = 0
            guestNameTitleLabel.alpha = 0
            guestSchoolTitleLabel.alpha = 0
            guestParentPhoneTitleLabel.alpha = 0
            guestNameLabel.alpha = 0
            guestSchoolLabel.alpha = 0
            guestParentPhoneLabel.alpha = 0
        }
        else {
            lineLabel.alpha = 1
            guestInfoTitleLabel.alpha = 1
            guestNameTitleLabel.alpha = 1
            guestSchoolTitleLabel.alpha = 1
            guestParentPhoneTitleLabel.alpha = 1
            guestNameLabel.alpha = 1
            guestSchoolLabel.alpha = 1
            guestParentPhoneLabel.alpha = 1
            
            guestNameLabel.text = selectedStudent.guestName
            guestSchoolLabel.text = selectedStudent.guestSchool
            guestParentPhoneLabel.text = selectedStudent.guestParentPhone
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! addGuestViewController
        nvc.database = database
        nvc.selectedStudent = selectedStudent
//        detailsStudentArray.append(selectedStudent)
//        nvc.selectedStudentArray = detailsStudentArray as NSArray
    }
    
    
}
