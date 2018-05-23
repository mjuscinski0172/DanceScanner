//
//  ListViewController.swift
//  DanceScanner
//
//  Created by Jimmy Rodriguez on 1/10/18.
//  Copyright © 2018 Michal Juscinski. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UITabBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var studentArray = [Student]()
    var filteredArray = [Student]()
    var alphabeticalStudentArray = [Student]()
    let database = CKContainer.default().publicCloudDatabase
    var isProm: Bool!

    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    var exportButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportData))
        navigationItem.setRightBarButton(exportButton, animated: true)
        
        //Sets colors for UI items
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.tintColor = .white

        tableView.backgroundColor = .black
        tableView.separatorColor = .black
        searchBar.backgroundImage = UIImage(named: "gray")
        
        resultsController.tableView.backgroundColor = .black
        resultsController.tableView.separatorColor = .black
        
        tableView.delegate = self
        tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        
        //Tells table to update when searched
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        
        //Sets appearance of Tab Bar
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue.lighter(by: 30)!], for: .selected)
        
        //Sets other properties of Tab Bar
        let tabBar = UITabBar(frame: CGRect(x: 0, y: 975, width: 770, height: 50))
        tabBar.delegate = self
        if isProm == true {
            tabBar.barTintColor = .black
        }
        else {
            tabBar.barTintColor = UIColor(red: 92.0/255.0, green: 60.0/255.0, blue: 31.0/255.0, alpha: 1)
        }
//        tabBar.barStyle = .black
        let purchaseTabButton = UITabBarItem(title: "Purchase Tickets", image: nil, tag: 1)
        let checkTabButton = UITabBarItem(title: "Check In/Out", image: nil, tag: 2)
        tabBar.setItems([purchaseTabButton, checkTabButton], animated: false)
        
        //Makes Tab Bar visible
        view.addSubview(tabBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isProm {
            self.navigationController?.navigationBar.barTintColor = .black
        }
        else {
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 92.0/255.0, green: 60.0/255.0, blue: 31.0/255.0, alpha: 1)
        }
    }
    
    @ objc func exportData() {
        let interval = TimeInterval(exactly: 0)
        let date = Date(timeIntervalSinceNow: interval!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YY"
        let dateString = dateFormatter.string(from: date)
        let fileName = "DanceExport_\(dateString).csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText: String = "Id Number,Last Name,First Name,Guest Name,Guest School,Student Food Choice,Guest Food Choice,Check In Time,Check Out Time\n"
        for student in studentArray {
            csvText += "\(student.idNumber),\(student.lastName),\(student.firstName),\(student.guestName),\(student.guestSchool),\(student.foodChoice),\(student.guestFoodChoice), \(student.checkInTime),\(student.checkOutTime)\n"
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.popoverPresentationController?.sourceView = self.view
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true, completion: nil)
            
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //When the purchase button on the Tab Bar is pressed, segue to the purchaseVC
        if item.tag == 1 {
            print("purchase")
            self.performSegue(withIdentifier: "tabPurchaseSegue2", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
            //When the check button on the Tab Bar is pressed, segue to the checkVC
        else if item.tag == 2{
            print("check")
            self.performSegue(withIdentifier: "tabCheckSegue2", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredArray = alphabeticalStudentArray.filter({ (studentArray:Student) -> Bool in
            //Updates the table to only show search results
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
        //Clears all arrays and pulls everything from CloudKit
        studentArray = []
        filteredArray = []
        createStudentArray()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            let student = alphabeticalStudentArray[indexPath.row]
            if student.foodChoice == 0 {
                cell.backgroundColor = UIColor(red: 1, green: 115.0/255.0, blue: 0, alpha: 1)
            }
            else {
                cell.backgroundColor = UIColor.darkGray.darker(by: 18)
            }
            cell.textLabel?.text = "                           " + "\(student.lastName), \(student.firstName)"
            cell.detailTextLabel?.text = "                                       " + student.guestName
            cell.detailTextLabel?.textColor = .lightGray
            cell.textLabel?.textColor = .white
            //Creates the status label and sets its text
            let labels = abc(cell: cell)
            let label = labels[0]
            label.textColor = .white
            label.text = "\(student.checkedInOrOut)".uppercased()
            if student.checkedInOrOut == "In" {
                label.textColor = UIColor.green.darker(by: 30)
            }
            if student.checkedInOrOut == "Out" {
                label.textColor = .red
            }
            let guestLabel = labels[1]
            guestLabel.textColor = .white
            guestLabel.font = UIFont.systemFont(ofSize: 10)
            guestLabel.text = "\(student.guestCheckIn)".uppercased()
            if student.guestCheckIn == "In" {
                guestLabel.textColor = UIColor.green.darker(by: 30)
            }
            if student.guestCheckIn == "Out" {
                guestLabel.textColor = .red
            }
            
            return cell
        }
        else {
            //If the prototype cannot be pulled (AKA this is the results controller), create a new cell and place the student that has been searched into the cell
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newCell")
            let student = filteredArray[indexPath.row]
            if student.foodChoice == 0 {
                cell.backgroundColor = UIColor(red: 1, green: 115.0/255.0, blue: 0, alpha: 1)
            }
            else {
                cell.backgroundColor = UIColor.darkGray.darker(by: 18)
            }
            cell.textLabel?.text = "                         " + "\(student.lastName), \(student.firstName)"
            cell.detailTextLabel?.text = "                                 " + student.guestName
            cell.detailTextLabel?.textColor = .lightGray
            cell.textLabel?.textColor = .white
            //            let label = UILabel(frame: CGRect(x: 5, y: 2, width: 115, height: 40))
            //Creates the status label and sets its text
            let labels = abc(cell: cell)
            let label = labels[0]
            label.textColor = .white
            label.text = "\(student.checkedInOrOut)".uppercased()
            if student.checkedInOrOut == "In" {
                label.textColor = UIColor.green.darker(by: 30)
            }
            if student.checkedInOrOut == "Out" {
                label.textColor = .red
            }
            //Creates the guest status label and sets its text
            let guestLabel = labels[1]
            guestLabel.textColor = .white
            guestLabel.font = UIFont.systemFont(ofSize: 10)
            guestLabel.text = "\(student.guestCheckIn)".uppercased()
            if student.guestCheckIn == "In" {
                guestLabel.textColor = UIColor.green.darker(by: 30)
            }
            if student.guestCheckIn == "Out" {
                guestLabel.textColor = .red
            }
            
            return cell
        }
        
    }
    
    func abc(cell: UITableViewCell) -> [UILabel] {
        if cell.subviews.count < 3 {
            //If the cell does not currently have a status label, create one
            let label = UILabel(frame: CGRect(x: 5, y: -10, width: 120, height: 55))
            label.textAlignment = .center
            label.layer.addBorder(edge: UIRectEdge.right, color: UIColor.black, thickness: 0.5)
            cell.addSubview(label)
            //Also create a label for the guest's status
            let guestLabel = UILabel(frame: CGRect(x: 5, y: 30, width: 120, height: 20))
            guestLabel.textAlignment = .center
            guestLabel.layer.addBorder(edge: .right, color: .black, thickness: 0.5)
            cell.addSubview(guestLabel)
            //Send both labels back
            return [label, guestLabel]
        }
        else {
            //If the cell does have a status label, pull that label from the cell and send it back
            let label = cell.subviews[2] as! UILabel
            let guestLabel = cell.subviews[3] as! UILabel
            return [label, guestLabel]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Displays the correct amount of cells based on the amount of students
        if tableView == resultsController.tableView{
            return filteredArray.count
        } else{
            return alphabeticalStudentArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If a cell on the resultsController is pressed, segue to the detailsVC
        self.performSegue(withIdentifier: "listToDetail", sender: (Any).self)
        resultsController.dismiss(animated: true, completion: nil)
    }
    
    func createStudentArray() {
        //Clears studentArray and queries CloudKit
        studentArray.removeAll()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            for student in records! {
                //Pulls every student's information
                let firstName = student.object(forKey: "firstName") as! String
                let lastName = student.object(forKey: "lastName") as! String
                let altIDNumber = student.object(forKey: "altIDNumber") as! String
                let idNumber = student.object(forKey: "idNumber") as! String
                let checkedInOrOut = student.object(forKey: "checkedInOrOut") as! String
                let checkInTime = student.object(forKey: "checkInTime") as! String
                let checkOutTime = student.object(forKey: "checkOutTime") as! String
                let studentParentName = student.object(forKey: "studentParentName") as! String
                let studentParentPhone = student.object(forKey: "studentParentPhone") as! String
                let studentParentCell = student.object(forKey: "studentParentCell") as! String
                let guestName = student.object(forKey: "guestName") as! String
                let guestSchool = student.object(forKey: "guestSchool") as! String
                let guestParentPhone = student.object(forKey: "guestParentPhone") as! String
                let guestCheckIn = student.object(forKey: "guestCheckIn") as! String
                let foodChoice = Int(student.object(forKey: "foodChoice") as! String)
                let guestFoodChoice = Int(student.object(forKey: "guestFoodChoice") as! String)
                //Creates an object of the Student class, puts all pulled information into it, and adds it to the array
                let newStudent = Student(firstName: firstName, lastName: lastName, altIDNumber: altIDNumber, idNumber: idNumber, checkedInOrOut: checkedInOrOut, checkInTime: checkInTime, checkOutTime: checkOutTime, guestName: guestName, guestSchool: guestSchool, guestParentPhone: guestParentPhone, guestCheckIn: guestCheckIn, studentParentName: studentParentName, studentParentPhone: studentParentPhone, studentParentCell: studentParentCell, foodChoice: foodChoice!, guestFoodChoice: guestFoodChoice!)
                self.studentArray.append(newStudent)
                
                self.alphabeticalStudentArray = self.studentArray.sorted(by: { $0.lastName < $1.lastName })
            }
            //Reloads the table with the new student
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Sends the student that was pressed to the detailsVC
        if segue.identifier == "listToDetail" {
            let nvc = segue.destination as! detailsViewController
            //        let indexPath = tableView.indexPathForSelectedRow!
            if let indexPath = tableView.indexPathForSelectedRow{
                nvc.selectedStudent = alphabeticalStudentArray[indexPath.row]
            }
            else {
                let indexPath = resultsController.tableView.indexPathForSelectedRow!
                nvc.selectedStudent = filteredArray[indexPath.row]
            }
            //        nvc.selectedStudent = studentArray[indexPath.row]
            nvc.database = database
        }
        else if segue.identifier == "tabPurchaseSegue2" {
            let nvc = segue.destination as! PurchaseScannerViewController
            nvc.isProm = isProm
        }
        else if segue.identifier == "tabCheckSegue2" {
            let nvc = segue.destination as! checkViewController
            nvc.isProm = isProm
        }
    }
    
    
    
}

