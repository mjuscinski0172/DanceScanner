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

class PurchaseScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var database =  CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func getJSON(altID: String){
            let urlString = "https://api.myjson.com/bins/16ljdv"
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url, completionHandler: { (myData, response, error) in
                if let JSONObject = try? JSONSerialization.jsonObject(with: myData!, options: .allowFragments) as! NSDictionary {
                    let studentArray = JSONObject.object(forKey: altID) as! NSArray
                    let studentDictionary = studentArray.firstObject as! NSDictionary
                    let firstName = studentDictionary.object(forKey: "First") as! NSString
                    let lastName = studentDictionary.object(forKey: "Last") as! NSString
                    let ID = studentDictionary.object(forKey: "ID") as! NSInteger
                
                    
                    let purchaseTicketsAlert = UIAlertController(title: "Found an ID", message: "Student: \(firstName) \(lastName)\nStudent ID: \(ID)", preferredStyle: .alert)
                    let purchaseTicketButton = UIAlertAction(title: "Purchase Ticket", style: .default, handler: { (action) in
                        let place = CKRecord(recordType: "Students")
                        place.setObject(firstName as CKRecordValue, forKey: "firstName")
                        place.setObject(lastName as CKRecordValue, forKey: "lastName")
                        place.setObject(String(ID) as CKRecordValue, forKey: "idNumber")
                        place.setObject(String(altID) as CKRecordValue, forKey: "altIDNumber")
                        place.setObject("Purchased" as CKRecordValue, forKey: "checkedInOrOut")
                        place.setObject("" as CKRecordValue, forKey: "checkInTime")
                        place.setObject("" as CKRecordValue, forKey: "checkOutTime")
                        self.database.save(place) { (record, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            self.runSession()
                        }
                    })
                    let addGuestButton = UIAlertAction(title: "Ticket with Guest", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "addGuestSegue", sender: self)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                        self.runSession()
                    })
                    purchaseTicketsAlert.addAction(purchaseTicketButton)
                    purchaseTicketsAlert.addAction(cancelAction)
                    purchaseTicketsAlert.addAction(addGuestButton)
                    self.present(purchaseTicketsAlert, animated: true, completion: nil)
                }
            }).resume()
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
                    getJSON(altID: readableCode.stringValue!)
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
