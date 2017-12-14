//
//  PurchaseScannerViewController.swift
//  DanceScanner
//
//  Created by Michal Juscinski on 12/5/17.
//  Copyright © 2017 Michal Juscinski. All rights reserved.
//

import UIKit
import AVFoundation

class PurchaseScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1ST BLOCK
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
        
        // 2ND BLOCK
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.code39]
        } else {
            scanningNotPossible()
        }
        
        // 3RD BLOCK
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
    }
    func barcodeDetected(code: String){
        // Let the user know we've found something.
        print(code)
        let alert = UIAlertController(title: "Found a Barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            
            // Remove the spaces.
            let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
            
            // EAN or UPC?
            // Check for added "0" at beginning of code.
            
            let trimmedCodeString = "\(trimmedCode)"
            var trimmedCodeNoZero: String
            
            if trimmedCodeString.hasPrefix("0") && trimmedCodeString.characters.count > 1 {
                trimmedCodeNoZero = String(trimmedCodeString.characters.dropFirst())
                
                // Send the doctored UPC to DataService.searchAPI()
//                DataService.searchAPI(trimmedCodeNoZero)
            } else {
//
//                 Send the doctored EAN to DataService.searchAPI()
//                DataService.searchAPI(trimmedCodeString)
            }
            
                self.navigationController?.popViewController(animated: true)
        }))
        
            self.present(alert, animated: true, completion: nil)
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "This device can't scan.", message: "How did you mess this up? It was only supposed to be sent to camera-equipped iPads!", preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Yeah, I really screwed this up", style: .destructive, handler: nil)
        alert.addAction(closeButton)
        present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("Hello")
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
           
            if let readableCode = barcodeReadable{
            //    print("x")
//                delete above /\ and uncomment below \/
                barcodeDetected(code: readableCode.stringValue!)
            }
            //make something other than vibrating
            
        }
    }
    
}
