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

    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = studentArray[indexPath]
        cell.textLabel?.text = "\(student.object(forKey: "firstName")) \(student.object(forKey: "lastName"))"
        cell.detailTextLabel?.text = student.object(forKey: "checkedInOrOut")
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentArray.count
    }
}
