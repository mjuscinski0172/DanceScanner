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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStudentArray()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = studentArray[indexPath.row]
        cell.textLabel?.text = "                         " + "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = "                                 " + student.guestName
        
        let label = UILabel(frame: CGRect(x: 5, y: 2, width: 115, height: 52))
        label.textAlignment = .center
        label.layer.addBorder(edge: UIRectEdge.right, color: UIColor.black, thickness: 1.5)
        label.text = "\(student.checkedInOrOut)".uppercased()
        if student.checkedInOrOut == "In" {
            label.textColor = UIColor.green.darker(by: 30)
        }
        if student.checkedInOrOut == "Out" {
            label.textColor = .red
        }
        cell.addSubview(label)
        
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
                let guestName = student.object(forKey: "guestName") as! String
                let guestSchool = student.object(forKey: "guestSchool") as! String
                let guestParentPhone = student.object(forKey: "guestParentPhone") as! String
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime, guestName: guestName, guestSchool: guestSchool, guestParentPhone: guestParentPhone)
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
