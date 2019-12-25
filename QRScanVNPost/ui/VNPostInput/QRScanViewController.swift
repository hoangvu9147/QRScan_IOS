//
//  QRScanViewController.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import SwiftyJSON


class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate {

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var captureSession: AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var uiPreviewLayer: UIView!
    var barCodeFrameView: UIView?
    var barCodeFrameView_1: UIView? //
    var barCodeFrameView_2: UIView? //
    var labelTextCode : UILabel?

    @IBOutlet weak var uiImgBarcode: UIImageView!
    @IBOutlet weak var uiReader: UIImageView!

    var initialized = false
    @IBOutlet weak var highlightView: UIView!
    var barcodeString : String = ""
    var onBarcode:((String) ->())?

    var isStartCamera = false
    var  detailInfoItemDatas = [DetailInfoItemData]()
    var idBarcodeScan = ""

    //Zebra


    // TODO: -- RFID -- Zebra --
    var listRfidZebra : NSMutableArray = NSMutableArray()
    var listBarcodeZebra : NSMutableArray = NSMutableArray()


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

    override func viewDidLoad() {
        super.viewDidLoad()
         uiReader.image = UIImage(named: "ico_readerConnect")

        self.navigationController?.isNavigationBarHidden = true
        uiPreviewLayer.isHidden = true
        uiImgBarcode.isHidden = true

        let tapImageViewTagGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImgQRcodeView(tapImageViewTagGestureRecognizer:)))
        uiImgBarcode.addGestureRecognizer(tapImageViewTagGestureRecognizer)
        uiImgBarcode.isUserInteractionEnabled = true


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isStartCamera{
            captureSession?.startRunning()
            isStartCamera = false
        }

       

//        self.appDelegate.barcodeScanZebra.onComplete = {
//            print( "-000000----self.appDelegate.barcodeScanZebra.isConnected-- - \($0)")
//        }

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: -- call Api

    func getApiDetailInfoProducted(idCode: String) {
        print("getDetailInfoProducted")
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let api = DetailInfoRequest(requestName:  String(format: QRRequestName.GET_DETAIL_PRODUCT_ITEM.rawValue, idCode), responseType: QRResponseType.json)
        api.get().execute(mfResponse: {
            (api,response,error) in
            if response?.result_code != 10 {
              print("---- result dataResponse -- \(String(describing: response?.dataResponse))")

                var count = 0
                if response?.dataResponse != nil {
                    let responseJson = response?.dataResponse as! JSON
                    if !Utils.isEmptyJson(json: responseJson, key: "order"){
                        let arr_json = responseJson["order"].array
                        count = (arr_json?.count)!
                        print("--- arr_json count \(arr_json!.count)")
                    }
                }



                if count > 0 {
                    _ = response?.toResponse(clazz: QRDetailInfoItemRespone.self)
                    MBProgressHUD.hide(for: self.view, animated: true)

                    let newViewController = QRScanInfoProductedViewController()
                    let  detailItemData = DetailInfoItemData.getDetailByBarcodeID(bar_code: self.idBarcodeScan)

                    newViewController.idBarcode = (detailItemData?.id)!
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }else{
                    self.showAlertInfoItemNone()
                }


            } else {
                self.showAlertInfoItemNone()
            }
        })

    }


    func showAlertInfoItemNone(){
        MBProgressHUD.hide(for: self.view, animated: true)

        // create the alert
        let alert = UIAlertController(title: "Thông tin sản phẩm", message: "Mã sản phẩm hiện tại không có trong hệ thống. \n Vui lòng thử lại!", preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.captureSession?.startRunning()
        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)

    }

    
    func loadViewBarcode(){

        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.removeFromSuperview()
            self.barCodeFrameView = nil
        }

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
        //        print("isrunning \(captureSession?.isRunning)");
        captureSession?.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //        var  uiFameBarcode_ :UIView?
        processBarCodeData(metadataObjects: metadataObjects)
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

            labelTextCode_?.isHidden = true
            return
        }

        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if barCodeTypes.contains(metadataObject.type) {
                // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
                let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
                // Initialize Frame to highlight the Bar Code
                print("processBarCodeData----33333--------metadataObject.stringValue! \(metadataObject.stringValue!)--")
                idBarcodeScan = metadataObject.stringValue!

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

        print("-----vule -----processBarCodeData----1111----------")
        

        captureSession?.stopRunning()

        // Call Api
//        let newViewController = QRScanInfoProductedViewController()
//        self.navigationController?.pushViewController(newViewController, animated: true)

        getApiDetailInfoProducted(idCode: idBarcodeScan);

        return



    }

    //MARK: --

    @IBAction func onPushHistory(_ sender : Any){
        uiImgBarcode.isHidden = true
        uiPreviewLayer.isHidden = true
        captureSession?.stopRunning()

        let newViewController = QRScanHistoryViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)


        //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let newViewController = storyBoard.instantiateViewController(withIdentifier: "history") as! QRScanHistoryViewController
        //        self.navigationController?.pushViewController(newViewController, animated: true)


    }


    @objc func tapImgQRcodeView(tapImageViewTagGestureRecognizer: UITapGestureRecognizer)
    {
        uiImgBarcode.isHidden = true
        uiPreviewLayer.isHidden = true
        captureSession?.stopRunning()
    }



    @IBAction func onReader(_ sender : Any){

        uiPreviewLayer.isHidden = true
        uiImgBarcode.isHidden = true
        captureSession?.stopRunning()

        let dialogICTag = MTDialogContentItemCode()
        dialogICTag.modalPresentationStyle = .overCurrentContext
        dialogICTag.onSencodeButton  = {
            print("----- $0 \($0)")
            self.idBarcodeScan = $0
            self.getApiDetailInfoProducted(idCode: $0)
            
//            let newViewController = QRScanInfoProductedViewController()
//            self.navigationController?.pushViewController(newViewController, animated: true)

        }
        self.present(dialogICTag, animated: false, completion: nil)

    }


    @IBAction func onQRcode(_ sender : Any){
        uiImgBarcode.isHidden = false
        uiPreviewLayer.isHidden = false
        loadViewBarcode()
    }

}
