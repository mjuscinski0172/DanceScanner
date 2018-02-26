 
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
        
        session = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            
        }
        catch {
            return
        }
        
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
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue.lighter(by: 30)!], for: .selected)
        
        let tabBar = UITabBar(frame: CGRect(x: 0, y: 975, width: 770, height: 50))
        tabBar.delegate = self
        tabBar.barStyle = .black
        let purchaseTabButton = UITabBarItem(title: "Purchase Tickets", image: nil, tag: 1)
        let listTabButton = UITabBarItem(title: "List", image: nil, tag: 3)
        tabBar.setItems([purchaseTabButton, listTabButton], animated: false)
        
        view.addSubview(tabBar)
        
        session.startRunning()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            print("purchase")
            self.performSegue(withIdentifier: "tabPurchaseSegue", sender: self)
            
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
        else if item.tag == 3 {
            print("list")
            self.performSegue(withIdentifier: "tabListSegue2", sender: self)
            
            var navigationArray = self.navigationController?.viewControllers ?? [Any]()
            navigationArray.remove(at: 1)
            navigationController?.viewControllers = (navigationArray as? [UIViewController])!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    func checkOnCloudKit(altID: String){
        let place = CKRecord(recordType: "Students")
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var correctedMinutes = "\(minutes)"
        
        if minutes < 10 {
            correctedMinutes = "0\(minutes)"
        }
        else if minutes >= 10{
            correctedMinutes = "\(minutes)"
        }
        let seconds = calendar.component(.second, from: date)
        let timeOf = "\(hour):\(correctedMinutes)"
        //        print("hours = \(hour):\(correctedMinutes):\(seconds)")
        
        let predicate =  NSPredicate(format: "altIDNumber = '\(altID)'")
        let query = CKQuery(recordType: "Students", predicate: predicate)
        var student: CKRecord!
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let myRecords = records {
                if let student = myRecords.first{
                    
                    if student.object(forKey: "checkedInOrOut") as! String == "Purchased" {
                        student.setObject("In" as CKRecordValue, forKey: "checkedInOrOut")
                        student.setObject(timeOf as CKRecordValue, forKey: "checkInTime")
                        
                        self.database.save(student) { (record, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    self.runSession()
                                })
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            if student.object(forKey: "guestName") as! String != "" {
                                let alert = UIAlertController(title: "Is the guest present?", message: nil, preferredStyle: .alert)
                                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                                    print(100)
                                    student.setObject("Present" as CKRecordValue, forKey: "guestCheckIn")
                                    self.runSession()
                                })
                                let noAction = UIAlertAction(title: "No", style: .destructive, handler: {(action) in
                                    student.setObject("Not Present" as CKRecordValue, forKey: "guestCheckIn")

                                    self.runSession()
                                })
                                alert.addAction(yesAction)
                                alert.addAction(noAction)
                                self.present(alert, animated: true, completion: nil)
                            }

                            else {
                                let alert = UIAlertController(title: "Checked In", message: nil, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    self.runSession()
                                })
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else if student.object(forKey: "checkedInOrOut") as! String == "In" {
                        student.setObject("Out" as CKRecordValue, forKey: "checkedInOrOut")
                        
                        student.setObject(timeOf as CKRecordValue, forKey: "checkOutTime")
                        
                        
                        
                        self.database.save(student) { (record, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.runSession()
                                })
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            else{
                                let alert = UIAlertController(title: "Checked Out", message: nil, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.runSession()
                                })
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)                        }
                        }
                    }
                    else if student.object(forKey: "checkedInOrOut") as! String == "Out" {
                        student.setObject("Out" as CKRecordValue, forKey: "checkedInOrOut")
                        //                    print("c")
                        self.database.save(student, completionHandler: { (record, error) in
                            let alert = UIAlertController(title: "Error", message: "This student has already been checked out", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.runSession()
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: "This student has not purchased tickets", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.runSession()
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                } else{
                    let alert = UIAlertController(title: "Error", message: "This student has not purchased a ticket", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.runSession()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "This device can't scan.", message: "How did you mess this up? It was only supposed to be sent to camera-equipped iPads!", preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Yeah, I really screwed this up", style: .destructive, handler: nil)
        alert.addAction(closeButton)
        present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopSession()
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = barcodeReadable{
                checkOnCloudKit(altID: readableCode.stringValue!)
            }
        }
    }
    
    func runSession() {
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
 }

 
