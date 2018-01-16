//
//  ListViewController.swift
//  DanceScanner
//
//  Created by Jimmy Rodriguez on 1/10/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var studentArray = [Student]()
    let database = CKContainer.default().publicCloudDatabase
    
    var myIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStudentArray()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = studentArray[myIndex]
        print(student)
        print("-----------------Chicken-----------------")
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.checkedInOrOut
        myIndex += 1
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentArray.count
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
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut)
                self.studentArray.append(newStudent)

            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
