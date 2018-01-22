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
    @IBOutlet weak var timeInTitleLabel: UILabel!
    @IBOutlet weak var timeOutTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
