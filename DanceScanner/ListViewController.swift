//
//  ListViewController.swift
//  DanceScanner
//
//  Created by Jimmy Rodriguez on 1/10/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var studentArray = [Student]()
    var filteredArray = [Student]()
    let database = CKContainer.default().publicCloudDatabase
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        tableView.backgroundColor = .black
        tableView.separatorColor = .black
        searchBar.backgroundImage = UIImage(named: "gray")
        
        resultsController.tableView.backgroundColor = .black
        resultsController.tableView.separatorColor = .black
        
        createStudentArray()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredArray = studentArray.filter({ (studentArray:Student) -> Bool in
            
            let fullName = studentArray.firstName + " " + studentArray.lastName
            
            if (studentArray.lastName.lowercased().contains(searchController.searchBar.text!.lowercased()) || studentArray.firstName.lowercased().contains(searchController.searchBar.text!.lowercased()) || fullName.lowercased().contains(searchController.searchBar.text!.lowercased()) || studentArray.guestName.lowercased().contains(searchController.searchBar.text!.lowercased())){
                return true
            } else{
                return false
            }
        })
        resultsController.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        tableView.reloadData()
        studentArray = []
        filteredArray = []
        createStudentArray()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            let student = studentArray[indexPath.row]
            cell.backgroundColor = UIColor.darkGray.darker(by: 25)
            cell.textLabel?.text = "                           " + "\(student.firstName) \(student.lastName)"
            cell.detailTextLabel?.text = "                                       " + student.guestName
            cell.detailTextLabel?.textColor = .lightGray
            cell.textLabel?.textColor = .white
            
            let label = UILabel(frame: CGRect(x: 5, y: 0, width: 120, height: 55))
            label.textColor = .white
            label.textAlignment = .center
            label.layer.addBorder(edge: UIRectEdge.right, color: UIColor.black, thickness: 0.5)
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
        else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newCell")
            let student = filteredArray[indexPath.row]
            cell.backgroundColor = UIColor.darkGray.darker(by: 25)
            cell.textLabel?.text = "                         " + "\(student.firstName) \(student.lastName)"
            cell.detailTextLabel?.text = "                                 " + student.guestName
            cell.detailTextLabel?.textColor = .lightGray
            cell.textLabel?.textColor = .white
            
//            let label = UILabel(frame: CGRect(x: 5, y: 2, width: 115, height: 40))
            let label = UILabel(frame: CGRect(x: 5, y: 0, width: 120, height: 55))
            label.textAlignment = .center
            label.textColor = .white
            label.layer.addBorder(edge: UIRectEdge.right, color: UIColor.black, thickness: 0.5)
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView{
            return filteredArray.count
        } else{
            return studentArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "listToDetail", sender: (Any).self)
        resultsController.dismiss(animated: true, completion: nil)
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
                let guestCheckIn = student.object(forKey: "guestCheckIn") as! String
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime, guestName: guestName, guestSchool: guestSchool, guestParentPhone: guestParentPhone, guestCheckIn: guestCheckIn)
                self.studentArray.append(newStudent)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! detailsViewController
        //        let indexPath = tableView.indexPathForSelectedRow!
        if let indexPath = tableView.indexPathForSelectedRow{
            nvc.selectedStudent = studentArray[indexPath.row]
        }
        else{
            let indexPath = resultsController.tableView.indexPathForSelectedRow!
            nvc.selectedStudent = filteredArray[indexPath.row]
        }
        //        nvc.selectedStudent = studentArray[indexPath.row]
        nvc.database = database
    }
}

