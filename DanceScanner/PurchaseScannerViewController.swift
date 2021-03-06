//
//  PurchaseScannerViewController.swift
//  DanceScanner
//
//  Created by Michal Juscinski on 12/5/17.
//  Copyright © 2017 Michal Juscinski. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class PurchaseScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITabBarDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var database =  CKContainer.default().publicCloudDatabase
    var studentDictionary: NSDictionary!
    var altId = ""
    var url: URL!
    var isProm: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isProm {
            self.navigationController?.navigationBar.barTintColor = .black
        }
        else {
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 92.0/255.0, green: 60.0/255.0, blue: 31.0/255.0, alpha: 1)
        }
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.tintColor = .white
        
        //Set up the background for the scanner
        session = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        }
        catch {
            return
        }
        //Adds input and output to session
        if (session.canAddInput(videoInput!)) {
            session.addInput(videoInput!)
        } else {
            scanningNotPossible()
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.code39]
        } else {
            scanningNotPossible()
        }
        //Presents camera for scanner
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //Sets the appearance of the Tab Bar
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue.lighter(by: 30)!], for: .selected)
        //Creates the Tab Bar and displays it
        let tabBar = UITabBar(frame: CGRect(x: 0, y: 975, width: 770, height: 50))
        tabBar.delegate = self
        if isProm == true {
            tabBar.barTintColor = .black
        }
        else {
            tabBar.barTintColor = UIColor(red: 92.0/255.0, green: 60.0/255.0, blue: 31.0/255.0, alpha: 1)
        }
//        tabBar.barStyle = .black
        let checkTabButton = UITabBarItem(title: "Check In/Out", image: nil, tag: 2)
        let listTabButton = UITabBarItem(title: "List", image: nil, tag: 3)
        tabBar.setItems([checkTabButton, listTabButton], animated: false)
        //Adds tab bar and runs scanning session
        view.addSubview(tabBar)
        
        session.startRunning()      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //When the check button on the Tab Bar is pressed, segue to the checkVC
        if item.tag == 2 {
            print("check")
            self.performSegue(withIdentifier: "tabCheckSegue", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
            //When the list button on the Tab Bar is pressed, segue to the listVC
        else if item.tag == 3 {
            print("list")
            self.performSegue(withIdentifier: "tabListSegue", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
    }
    
    func getJSON(altID: String){
        //Connects to JSON and pulls data
        //Old URL https://api.myjson.com/bins/16mtrl
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "JSONurl", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let asset = records?.first?.object(forKey: "JSONData") as? CKAsset,
                let myData = NSData(contentsOf: asset.fileURL)
            {
                if let JSONObject = try? JSONSerialization.jsonObject(with: myData as Data, options: .allowFragments) as! NSDictionary {
                //Takes JSON information and places them into local varialbes
                    guard let dictionary = JSONObject.object(forKey: altID) as? NSDictionary else {
                        let alert = UIAlertController(title: "Error", message: "Student not Found", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                            self.runSession()
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                self.studentDictionary = dictionary
                let firstName = self.studentDictionary.object(forKey: "FIRST") as! NSString
                let lastName = self.studentDictionary.object(forKey: "LAST") as! NSString
                let ID = self.studentDictionary.object(forKey: "ID") as! NSInteger
                let parentFirst = self.studentDictionary.object(forKey: "GRDFIRST") as! NSString
                let parentLast = self.studentDictionary.object(forKey: "GRDLAST") as! NSString
                let parentCell = self.studentDictionary.object(forKey: "GRDCELL") as! NSString
                let parentHouseHold = self.studentDictionary.object(forKey: "GRDHHOLD") as! NSString
                
                //Query the database for the altID that was scanned
                let predicate =  NSPredicate(format: "altIDNumber = '\(altID)'")
                let query = CKQuery(recordType: "Students", predicate: predicate)
                self.database.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                    if error != nil {
                        //Inform the user of any error
                        let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.runSession()
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if (records?.count)! > 0 {
                        //Inform the user that the student is already purchased
                        let alert = UIAlertController(title: "Error", message: "The student already has a ticket", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.runSession()
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        if self.isProm == false {
                            //Creates an alert that allows the user to confirm the purchase with 3 buttons
                            let purchaseTicketsAlert = UIAlertController(title: "Found an ID", message: "Student: \(firstName) \(lastName)\nStudent ID: \(ID)", preferredStyle: .alert)
                            let purchaseTicketButton = UIAlertAction(title: "Purchase Ticket", style: .default, handler: { (action) in
                                self.purchaseTicket(firstName: firstName as String, lastName: lastName as String, ID: String(ID), altID: String(altID), parentName: String(parentFirst) + " " + String(parentLast), parentCell: String(parentCell), parentHouseHold: String(parentHouseHold), foodChoice: "0")
                            })
                            let addGuestButton = UIAlertAction(title: "Ticket with Guest", style: .default, handler: { (action) in
                                self.performSegue(withIdentifier: "addGuestSegue", sender: self)
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                                self.runSession()
                            })
                            //Adds all buttons and presents alert
                            purchaseTicketsAlert.addAction(purchaseTicketButton)
                            purchaseTicketsAlert.addAction(cancelAction)
                            purchaseTicketsAlert.addAction(addGuestButton)
                            self.present(purchaseTicketsAlert, animated: true, completion: nil)
                        }
                        else {
                            //Creates an alert that allows the user to confirm the purchase with 3 buttons (Prom edition)
                            let purchaseTicketsAlert = UIAlertController(title: "Found an ID", message: "Student: \(firstName) \(lastName)\nStudent ID: \(ID)\n", preferredStyle: .alert)
                            let purchaseTicketButton = UIAlertAction(title: "Purchase Ticket", style: .default, handler: { (action) in
                                //Creates an alert to check for food choices
                                let fuudAlert = UIAlertController(title: "Select Food Choice", message: "Which food choice does the student want?", preferredStyle: .alert)
                                let oneAction = UIAlertAction(title: "1", style: .default, handler: { (action) in
                                    //Purchases a ticket with food choice 1
                                    self.purchaseTicket(firstName: firstName as String, lastName: lastName as String, ID: String(ID), altID: String(altID), parentName: String(parentFirst) + " " + String(parentLast), parentCell: String(parentCell), parentHouseHold: String(parentHouseHold), foodChoice: "1")
                                })
                                let twoAction = UIAlertAction(title: "2", style: .default, handler: { (action) in
                                    //Purchases a ticket with food choice 2
                                    self.purchaseTicket(firstName: firstName as String, lastName: lastName as String, ID: String(ID), altID: String(altID), parentName: String(parentFirst) + " " + String(parentLast), parentCell: String(parentCell), parentHouseHold: String(parentHouseHold), foodChoice: "2")
                                })
                                let threeAction = UIAlertAction(title: "3", style: .default, handler: { (action) in
                                    //Purchases a ticket with food choice 3
                                    self.purchaseTicket(firstName: firstName as String, lastName: lastName as String, ID: String(ID), altID: String(altID), parentName: String(parentFirst) + " " + String(parentLast), parentCell: String(parentCell), parentHouseHold: String(parentHouseHold), foodChoice: "3")
                                })
                                let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                                    self.runSession()
                                })
                                //Adds all buttons and presents alert
                                fuudAlert.addAction(oneAction)
                                fuudAlert.addAction(twoAction)
                                fuudAlert.addAction(threeAction)
                                fuudAlert.addAction(cancelButton)
                                self.present(fuudAlert, animated: true, completion: nil)
                            })
                            let addGuestButton = UIAlertAction(title: "Ticket with Guest", style: .default, handler: { (action) in
                                self.performSegue(withIdentifier: "addGuestSegue", sender: self)
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                                self.runSession()
                            })
                            //Adds all buttons and presents alert
                            purchaseTicketsAlert.addAction(purchaseTicketButton)
                            purchaseTicketsAlert.addAction(cancelAction)
                            purchaseTicketsAlert.addAction(addGuestButton)
                            self.present(purchaseTicketsAlert, animated: true, completion: nil)
                        }}
                })
            }
    }}
    }
    
    func purchaseTicket(firstName: String, lastName: String, ID: String, altID: String, parentName: String, parentCell: String, parentHouseHold: String, foodChoice: String) {
        //Sets the information of the student on CloudKit
        let place = CKRecord(recordType: "Students")
        place.setObject(firstName as CKRecordValue, forKey: "firstName")
        place.setObject(lastName as CKRecordValue, forKey: "lastName")
        place.setObject(String(ID) as CKRecordValue, forKey: "idNumber")
        place.setObject(String(altID) as CKRecordValue, forKey: "altIDNumber")
        place.setObject("Purchased" as CKRecordValue, forKey: "checkedInOrOut")
        place.setObject("" as CKRecordValue, forKey: "checkInTime")
        place.setObject("" as CKRecordValue, forKey: "checkOutTime")
        place.setObject(parentHouseHold as CKRecordValue, forKey: "studentParentPhone")
        place.setObject(parentName as CKRecordValue, forKey: "studentParentName")
        place.setObject(parentCell as CKRecordValue, forKey: "studentParentCell")
        place.setObject("" as CKRecordValue, forKey: "guestName")
        place.setObject("" as CKRecordValue, forKey: "guestSchool")
        place.setObject("" as CKRecordValue, forKey: "guestParentPhone")
        place.setObject("" as CKRecordValue, forKey: "guestCheckIn")
        place.setObject("0" as CKRecordValue, forKey: "guestFoodChoice")
        place.setObject(foodChoice as CKRecordValue, forKey: "foodChoice")
        //Saves student and checks for error
        self.database.save(place) { (record, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.runSession()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Purchase Successful", message: "This student now has a ticket", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.runSession()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func scanningNotPossible() {
        //Presents an alert if it is impossible to scan
        let alert = UIAlertController(title: "This device can't scan.", message: "How did you mess this up? It was only supposed to be sent to camera-equipped iPads!", preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Yeah, I really screwed this up", style: .destructive, handler: nil)
        alert.addAction(closeButton)
        present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //Places readable value of scanned barcode into the variable altID
        stopSession()
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = barcodeReadable{
                self.altId = readableCode.stringValue!
                getJSON(altID: altId)
                
            }
        }
    }
    
    func runSession() {
        //Starts to run the session again
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    func stopSession() {
        //Stops the session
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Shares information pulled from JSON with the addGuestVC
        if segue.identifier == "addGuestSegue" {
            let nvc = segue.destination as! addGuestViewController
            nvc.studentDictionary = studentDictionary
            nvc.altId = altId
            nvc.database = database
            nvc.isProm = isProm
        }
        else if segue.identifier == "tabCheckSegue" {
            let nvc = segue.destination as! checkViewController
            nvc.isProm = isProm
        }
        else if segue.identifier == "tabListSegue" {
            let nvc = segue.destination as! ListViewController
            nvc.isProm = isProm
        }
    }
    
}
