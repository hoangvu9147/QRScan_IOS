//
//  ViewController.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate {

    var captureSession: AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var uiPreviewLayer: UIView!
    @IBOutlet weak var btnCaptureBoder: UIView!
    @IBOutlet weak var btnCapture: UIView!
    @IBOutlet weak var lbBarCode: UILabel!

    @IBOutlet weak var uiFameBarcode: UIView!


    var barCodeFrameView: UIView?
    var barCodeFrameView_1: UIView? //
    var barCodeFrameView_2: UIView? //
    var labelTextCode : UILabel?

    var initialized = false
    @IBOutlet weak var highlightView: UIView!



    var barcodeString : String = ""
    var onBarcode:((String) ->())?


    let barCodeTypes = [AVMetadataObject.ObjectType.upce,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.code39Mod43,
                        AVMetadataObject.ObjectType.code93,
                        AVMetadataObject.ObjectType.code128,
                        AVMetadataObject.ObjectType.ean8,
                        AVMetadataObject.ObjectType.ean13,
                        AVMetadataObject.ObjectType.aztec,
                        AVMetadataObject.ObjectType.pdf417,
                        AVMetadataObject.ObjectType.itf14,
                        AVMetadataObject.ObjectType.dataMatrix,
                        AVMetadataObject.ObjectType.interleaved2of5,
                        AVMetadataObject.ObjectType.qr]

    //    var crosshairView: CrosshairView? = nil // For Extra credit section 2



    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbBarCode.isHidden = true
//        if UIDevice.current.modelName != "Simulator"{
            loadViewBarcode()
//        }
        drawCricleButton()

        //        uiFameBarcode.layer.borderWidth = 1
        //        uiFameBarcode.layer.borderColor = UIColor(red: 101/255, green: 228/255, blue: 233/255, alpha: 1.0).cgColor as CGColor
        //        uiFameBarcode.layer.cornerRadius = 1


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadViewBarcode()

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadViewBarcode(){

        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.removeFromSuperview()
            self.barCodeFrameView = nil
        }
        var success = false
        var accessDenied = false
        var accessRequested = false
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.removeFromSuperview()
            self.barCodeFrameView = nil
        }


        /// view 1
        // Extra credit section 3
        if let barCodeFrameView_1 = barCodeFrameView_1 {
            barCodeFrameView_1.removeFromSuperview()
            self.barCodeFrameView_1 = nil
        }
        if let barCodeFrameView_1 = barCodeFrameView_1 {
            barCodeFrameView_1.removeFromSuperview()
            self.barCodeFrameView_1 = nil
        }

        if let barCodeFrameView_2 = barCodeFrameView_2 {
            barCodeFrameView_2.removeFromSuperview()
            self.barCodeFrameView_2 = nil
        }
        if let barCodeFrameView_2 = barCodeFrameView_2 {
            barCodeFrameView_2.removeFromSuperview()
            self.barCodeFrameView_2 = nil
        }
        if let lableUi = labelTextCode{
            lableUi.removeFromSuperview()
            self.labelTextCode = nil
        }



        //----------------


        captureSession = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        let error: Error? = nil
        var videoInput: AVCaptureDeviceInput? = nil
        if let aDevice = videoCaptureDevice {
            videoInput = try? AVCaptureDeviceInput(device: aDevice)
        }
        if videoInput != nil {
            if let videoInput = videoInput {
                captureSession?.addInput(videoInput)
            }
        } else {
            if let anError = error {
                print("Error: \(anError)")
            }
        }
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8, .code39, .code128, .pdf417, .aztec, .code39Mod43, .upce, .code93, .interleaved2of5, .itf14, .dataMatrix]
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)

        previewLayer?.frame = uiPreviewLayer.bounds
        previewLayer?.videoGravity = .resizeAspectFill


        uiPreviewLayer.layer.addSublayer(previewLayer!)
        captureSession?.startRunning()
    }



    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //        var  uiFameBarcode_ :UIView?
        processBarCodeData(metadataObjects: metadataObjects)

        //        if let metadataObject = metadataObjects.first {
        //            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        //            guard let stringValue = readableObject.stringValue else { return }
        //            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //
        //            let xCord = readableObject.bounds.origin.x * self.uiPreviewLayer.frame.size.width
        //            var yCord = (1 - readableObject.bounds.origin.y) * self.uiPreviewLayer.frame.size.height
        //            let width = readableObject.bounds.size.width * self.uiPreviewLayer.frame.size.width
        //            var height = -1 * readableObject.bounds.size.height * self.uiPreviewLayer.frame.size.height
        //            yCord += height
        //            height *= -1
        //
        ////            lbBarCode = UILabel(frame: CGRect(x: xCord, y: yCord, width: height, height: width))
        //            self.lbBarCode.isHidden = false
        //            lbBarCode.text = stringValue
        //            barcodeString = stringValue
        //            print("--Code = \(stringValue) xCord \(xCord) yCord \(yCord) width \(width) height \(height)")
        ////            uiPreviewLayer.addSubview(uiFameBarcode_!)
        //
        //        }else{
        //            self.lbBarCode.isHidden = true
        //        }
    }

    func processBarCodeData(metadataObjects: [AVMetadataObject]) {

        let labelTextCode_  :UILabel?
        labelTextCode_  = UILabel(frame: CGRect(x: 0, y: 30.0, width: 200, height: 21))
        labelTextCode_?.textAlignment = .center
        labelTextCode_?.textColor = UIColor(red: 49/255, green: 247/255, blue: 246/255, alpha: 1.0)


        if metadataObjects.count == 0 {
            print("processBarCodeData----1111----------")
            barCodeFrameView?.frame = CGRect.zero // Extra credit section 3
            barCodeFrameView_1?.frame = CGRect.zero
            labelTextCode_?.frame = CGRect.zero
            //            barCodeFrameView_1?.removeFromSuperview()
            //            barCodeFrameView?.removeFromSuperview()
            if let barCodeFrameView = barCodeFrameView {
                barCodeFrameView.removeFromSuperview()
                self.barCodeFrameView = nil
            }
            if let barCodeFrameView_1 = barCodeFrameView_1 {
                barCodeFrameView_1.removeFromSuperview()
                self.barCodeFrameView_1 = nil
            }
            lbBarCode.text = ""
            labelTextCode_?.text = ""
            labelTextCode_?.isHidden = true
            return
        }




        for metadata in metadataObjects {
            for symbology in barCodeTypes{
                if metadata.type == symbology {
                    print("processBarCodeData----2222255555----------")
                    //---get the screen coordinates of the barcode scanned---
                    let barCodeObject = previewLayer?.transformedMetadataObject(for: metadata)
                    let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
                    print("processBarCodeData----2222255555------metadataObject---- \(metadataObject?.stringValue)")

                    //                    print("origin x: \(String(describing: barCodeObject?.bounds.origin.x))")
                    //                    print("origin y: \(String(describing: barCodeObject?.bounds.origin.y))")
                    //                    print("size width: \(String(describing: barCodeObject?.bounds.size.width))")
                    //                    print("size height: \(String(describing: barCodeObject?.bounds.size.height))")

                    if self.barCodeFrameView == nil{
                        self.barCodeFrameView = UIView()
                        if let barCodeFrameView = self.barCodeFrameView {
                            barCodeFrameView.layer.borderColor = UIColor(red: 49/255, green: 247/255, blue: 246/255, alpha: 1.0).cgColor as CGColor
                            barCodeFrameView.layer.borderWidth = 2
                            self.view.addSubview(barCodeFrameView)
                            self.view.bringSubview(toFront: barCodeFrameView)
                        }
                    }
                    labelTextCode_?.text = ""
                    labelTextCode_?.text = metadataObject?.stringValue
                    self.barCodeFrameView?.addSubview(labelTextCode_!)
                    self.barCodeFrameView?.frame = barCodeObject!.bounds
                }else{
                    labelTextCode_?.text = ""
                    //                    labelTextCode_?.isHidden = true
                }
            }

        }





        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if barCodeTypes.contains(metadataObject.type) {
                // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
                let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
                // Initialize Frame to highlight the Bar Code
                print("processBarCodeData----33333--------metadataObject.stringValue! \(metadataObject.stringValue!)--")
                let  textBarcode = metadataObject.stringValue!

                if self.barCodeFrameView_1 == nil &&  self.barCodeFrameView_1 != self.barCodeFrameView{
                    self.barCodeFrameView_1 = UIView()

                    if let barCodeFrameView_1 = self.barCodeFrameView_1 {
                        print("processBarCodeData----767676767676--------metadataObject.stringValue!  --- textBarcode \(textBarcode)--")
                        barCodeFrameView_1.layer.borderColor = UIColor(red: 49/255, green: 247/255, blue: 246/255, alpha: 1.0).cgColor as CGColor
                        barCodeFrameView_1.layer.borderWidth = 2

                        self.view.addSubview(barCodeFrameView_1)
                        self.view.bringSubview(toFront: barCodeFrameView_1)
                    }


                }
                //
                labelTextCode_?.text = ""
                labelTextCode_?.text = textBarcode
                self.barCodeFrameView_1?.addSubview(labelTextCode_!)
                self.barCodeFrameView_1?.frame = barCodeObject!.bounds
            }

        }else{
            labelTextCode_?.text = ""
            labelTextCode_?.isHidden = true
        }

    }

    func drawCricleButton(){

//        btnCapture.layer.masksToBounds = false
//        btnCapture.layer.cornerRadius = btnCapture.frame.height/2
//        btnCapture.clipsToBounds = true
//
//        btnCaptureBoder.layer.borderWidth = 1
//        btnCaptureBoder.layer.masksToBounds = false
//        btnCaptureBoder.layer.borderColor = UIColor.white.cgColor
//        btnCaptureBoder.layer.cornerRadius = btnCaptureBoder.frame.height/2
//        btnCaptureBoder.backgroundColor = UIColor.white
//        btnCaptureBoder.clipsToBounds = true

    }

    @IBAction func onCLose(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onBarcode(_ sender : Any){
        if barcodeString.count > 0 {
            dismiss(animated: true, completion: nil)
            onBarcode?(barcodeString)
        }
    }
}

