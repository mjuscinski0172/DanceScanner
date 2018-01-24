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
        cell.textLabel?.text = "                    " + "\(student.firstName) \(student.lastName)"
        myIndex += 1
        
        let label = UILabel(frame: CGRect(x: 5, y: 2, width: 90, height: 40))
        label.text = "\(student.checkedInOrOut)"
        if student.checkedInOrOut == "In" {
            label.textColor = .green
        }
        if student.checkedInOrOut == "Out" {
            label.textColor = .red
        }
        cell.addSubview(label)
        
//        let borderLabel = UILabel(frame: CGRect(x: 90, y: 0, width: 2, height: 40))
//        label.backgroundColor = .black
//        cell.addSubview(borderLabel)
        
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
                let checkInTime = student.object(forKey: "checkInTime") as! String
                let checkOutTime = student.object(forKey: "checkOutTime") as! String
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime)
                self.studentArray.append(newStudent)

            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! detailsViewController
        let indexPath = tableView.indexPathForSelectedRow!
        nvc.selectedStudent = studentArray[indexPath.row]
        nvc.database = database
    }
}
