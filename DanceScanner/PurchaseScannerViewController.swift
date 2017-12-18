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
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    // random comment
    // another random comment
    
    func getJSON(altID: String){
        let alert = UIAlertController(title: "Found a Barcode!", message: altID, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            
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
                getJSON(altID: readableCode.stringValue!)
            }
            
        }
    }
    
}
