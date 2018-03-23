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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        //        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.red.lighter(by: 35)], for: .normal)
        
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
        tabBar.barStyle = .black
        let checkTabButton = UITabBarItem(title: "Check In/Out", image: nil, tag: 2)
        let listTabButton = UITabBarItem(title: "List", image: nil, tag: 3)
        tabBar.setItems([checkTabButton, listTabButton], animated: false)
        //Adds tab bar and runs scanning session
        view.addSubview(tabBar)
        
        //Pulls the URL for the JSON
        var urlString = ""
        let predicate = NSPredicate(value: true)
        let JSONQuery = CKQuery(recordType: "JSONurl", predicate: predicate)
        database.perform(JSONQuery, inZoneWith: nil) { (records, error) in
            urlString = records?.first?.object(forKey: "studentInfoUrl")! as! String
            self.url = URL(string: urlString)!
        }
        
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
        URLSession.shared.dataTask(with: self.url, completionHandler: { (myData, response, error) in
            if let JSONObject = try? JSONSerialization.jsonObject(with: myData!, options: .allowFragments) as! NSDictionary {
                //Takes JSON information and places them into local varialbes
                self.studentDictionary = JSONObject.object(forKey: altID) as! NSDictionary
                let firstName = self.studentDictionary.object(forKey: "FIRST") as! NSString
                let lastName = self.studentDictionary.object(forKey: "LAST") as! NSString
                let ID = self.studentDictionary.object(forKey: "ID") as! NSInteger
                let parentFirst = self.studentDictionary.object(forKey: "GRDFIRST") as! NSString
                let parentLast = self.studentDictionary.object(forKey: "GRDLAST") as! NSString
                let parentCell = self.studentDictionary.object(forKey: "GRDCELL") as! NSString
                let parentHouseHold = self.studentDictionary.object(forKey: "GRDHHOLD") as! NSString
                
                //Creates an alert that allows the user to confirm the purchase with 3 buttons
                let purchaseTicketsAlert = UIAlertController(title: "Found an ID", message: "Student: \(firstName) \(lastName)\nStudent ID: \(ID)", preferredStyle: .alert)
                let purchaseTicketButton = UIAlertAction(title: "Purchase Ticket", style: .default, handler: { (action) in
                    self.purchaseTicket(firstName: firstName as String, lastName: lastName as String, ID: String(ID), altID: String(altID), parentName: String(parentFirst) + " " + String(parentLast), parentCell: String(parentCell), parentHouseHold: String(parentHouseHold))
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
        }).resume()
    }
    
    func purchaseTicket(firstName: String, lastName: String, ID: String, altID: String, parentName: String, parentCell: String, parentHouseHold: String) {
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
        }
    }
    
}
