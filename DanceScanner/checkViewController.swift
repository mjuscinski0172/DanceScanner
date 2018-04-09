 
 //  checkViewController.swift
 //  DanceScanner
 //
 //  Created by Akhil Nair on 1/9/18.
 //  Copyright © 2018 Michal Juscinski. All rights reserved.
 //
 
 import UIKit
 import AVKit
 import CloudKit
 
 class checkViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITabBarDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var firstTimeCalled = true
    var database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.tintColor = .white
        
        //Sets up session that will scan barcode
        session = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            
        }
        catch {
            return
        }
        //Add input and output
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
        //Set the preview layer to be visible to the user
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        //Sets the appearance of the tab bar
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue.lighter(by: 30)!], for: .selected)
        //Finish setting up tab bar
        let tabBar = UITabBar(frame: CGRect(x: 0, y: 975, width: 770, height: 50))
        tabBar.delegate = self
        tabBar.barStyle = .black
        let purchaseTabButton = UITabBarItem(title: "Purchase Tickets", image: nil, tag: 1)
        let listTabButton = UITabBarItem(title: "List", image: nil, tag: 3)
        tabBar.setItems([purchaseTabButton, listTabButton], animated: false)
        //Adds tab bar and runs scanning session
        view.addSubview(tabBar)
        
        session.startRunning()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //When the purchase button on the Tab Bar is pressed, segue to the purchaseVC
        if item.tag == 1 {
            print("purchase")
            self.performSegue(withIdentifier: "tabPurchaseSegue", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
        //When the list button on the Tab Bar is pressed, segue to the listVC
        else if item.tag == 3 {
            print("list")
            self.performSegue(withIdentifier: "tabListSegue2", sender: self)
            //Removes the current VC from the stack
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Runs the session as the view appears
        super.viewWillAppear(animated)
        runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Stops the session as the view disappears
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    func checkOnCloudKit(altID: String){
        //Gets time information from the calendar
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var correctedMinutes = "\(minutes)"
        //If minutes is a single digit number, add a 0 in front to make it look better
        if minutes < 10 {
            correctedMinutes = "0\(minutes)"
        }
        else if minutes >= 10{
            correctedMinutes = "\(minutes)"
        }
        let timeOf = "\(hour):\(correctedMinutes)"
        //Query the database for the altID that was scanned
        let predicate =  NSPredicate(format: "altIDNumber = '\(altID)'")
        let query = CKQuery(recordType: "Students", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let myRecords = records {
                if let student = myRecords.first {
                    if student.object(forKey: "checkedInOrOut") as! String == "Purchased" {
                        //If the student has purchased a ticket, run the following
                        if student.object(forKey: "guestName") as! String != "" {
                            //Creates an alert if there is a guest
                            let alertPleaseWork = UIAlertController(title: "Check In", message: "Is the student's guest, \(student.object(forKey: "guestName")!), here?", preferredStyle: .alert)
                            let noAction = UIAlertAction(title: "No", style: .destructive, handler: {(action) in
                                self.runSession()
                            })
                            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                                //Tells the function to set the student as in if the guest is present
                                self.setInOrOut(message: "In", student: student, timeOf: timeOf)
                            })
                            //Adds all buttons and presents guest alert
                            alertPleaseWork.addAction(yesAction)
                            alertPleaseWork.addAction(noAction)
                            self.present(alertPleaseWork, animated: true, completion: nil)
                        }
                        else {
                            //If there is no guest, tells the function to set the student as in
                            self.setInOrOut(message: "In", student: student, timeOf: timeOf)
                        }
                    }
                    else if student.object(forKey: "checkedInOrOut") as! String == "In" {
                        //If the student has been checked in, run the following
                        if student.object(forKey: "guestName") as! String != "" {
                            //Creates an alert if there is a guest
                            let guestAlert = UIAlertController(title: "Check Out", message: "Is the student's guest \(student.object(forKey: "guestName")!) also checking out?", preferredStyle: .alert)
                            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                                self.runSession()
                            })
                            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                //Tells function to set the student as out if the guest is present
                                self.setInOrOut(message: "Out", student: student, timeOf: timeOf)
                            })
                            //Adds all buttons and presents guest alert
                            guestAlert.addAction(yesAction)
                            guestAlert.addAction(noAction)
                            self.present(guestAlert, animated: true, completion: nil)
                        }
                        else {
                            //If there is no guest, tell the function to set the student as out
                            self.setInOrOut(message: "Out", student: student, timeOf: timeOf)
                        }
                    }
                    else if student.object(forKey: "checkedInOrOut") as! String == "Out" {
                        //If the student has already been checked out, tells the function to display an error message
                        self.setInOrOut(message: "This student has already been checked out and cannot be allowed back into the dance", student: nil, timeOf: nil)
                    }
                    else {
                        //If the student is not one of the 3 status settings, tells the function to display an error message
                        self.setInOrOut(message: "This student has not purchased a ticket", student: nil, timeOf: nil)
                    }
                } else{
                    //If the student cannot be found in the records, tells the function to display an error message
                    self.setInOrOut(message: "This student has not purchased a ticket", student: nil, timeOf: nil)
                }
            }
        }
    }
    
    func setInOrOut(message: String, student: CKRecord!, timeOf: String!){
        if message == "In" || message == "Out" {
            //If the function has been called to check someone in or out, set that student to be the correct status
            student.setObject(message as CKRecordValue, forKey: "checkedInOrOut")
            student.setObject(timeOf as CKRecordValue, forKey: "check\(message)Time")
            self.database.save(student, completionHandler: { (record, error) in
                //If the database returns an error while trying to save the student to CK, display an error message
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.runSession()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                //If there is no error, inform the user that the change has been completed
                else {
                    let alert = UIAlertController(title: "Checked \(message)", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.runSession()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            //If the function has been called due to an error, create an alert to display the error message
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.runSession()
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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
        //Checks readable value of the altID against the CK database
        stopSession()
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = barcodeReadable{
                checkOnCloudKit(altID: readableCode.stringValue!)
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
 }
 
 
