//
//  MTDialogContentItemCode.swift
//  Monistor
//
//  Created by lhvu on 2018/06/06.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import UIKit

class MTDialogContentItemCode: UIViewController {

    
    var onEnter: (() -> ())?
    var onFristButton: (()->())?
    var onSencodeButton : ((String)->())?


    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak private var backgroundView: UIView!

    @IBOutlet weak private var lbTitle: UILabel!
    @IBOutlet weak private var lbMessage: UILabel!
    @IBOutlet weak private var tfInput: UITextField!

    @IBOutlet weak private var btnfrist: UIButton!
    @IBOutlet weak private var btnSencond: UIButton!
    @IBOutlet weak private var btnCenter: UIButton!

    @IBOutlet weak private var uiViewOneButton: UIView!
    @IBOutlet weak private var uiViewTwoButton: UIView!

    private var message = ""
    private var titleStr = ""
    private var fristButtonTitle: String?
    private var sencondButtonTitle: String?
    private var centerButtonTitle: String?
    private var tfInputStr = ""

    init() {
        super.init(nibName: "MTDialogContentItemCode", bundle: nil)
    }

    convenience init(_ title: String,_ message: String, _ centerButtonTitle: String) {
        self.init()
//        uiViewTwoButton.isHidden = true
        self.titleStr = title
        self.message = message
        self.centerButtonTitle = centerButtonTitle
    }


    convenience init(_ title: String,_ message: String, _ fristButtonTitle: String,_ sencondButtonTitle: String, _ tfinput : String) {
        self.init()
//         uiViewTwoButton.isHidden = false
        self.titleStr = title
        self.message = message
        self.fristButtonTitle = fristButtonTitle
        self.sencondButtonTitle = sencondButtonTitle
        self.tfInputStr = tfinput

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        for device in appDelegate.barcodeScanZebra.deviceList {
            if let rawDevice = device as? SbtScannerInfo {
                print( "-----334343434   -- \(String(rawDevice.getScannerID()))")
                print("-----54454644455   -- \(String(rawDevice.getScannerName()))")
                connectBarcodeZebra(idBarcode: Int(rawDevice.getScannerID()),nameBarocde: rawDevice.getScannerName())
            }
        }

        print( "-self.appDelegate.barcodeScanZebra.isConnected-- - \(self.appDelegate.barcodeScanZebra.isConnected)")
        if  self.appDelegate.barcodeScanZebra.isConnected {
//            uiReader.image = UIImage(named: "ico_readerConnect")
        }


        self.appDelegate.barcodeScanZebra.onReadBarcodeHandler = {
            print( "-barcodeScanZebra -- - \($0)")
            self.tfInput.text = $0
        }
    }


   //MARK: reader
    func connectBarcodeZebra( idBarcode : Int, nameBarocde : String){
        //        let idBarcode = SettingApp.instance.getIDValueDeviceZebra() //1
        //        let nameBarocde = SettingApp.instance.getNameValueDeviceZebra()//CS407018027522506829
        var array: [BarcodeScannerDevice] = []

        array.append(BarcodeScannerDevice(id: Int32(idBarcode),name: nameBarocde))
        print( "--- count array -- \(array.count)")
        self.appDelegate.barcodeScanZebra.connect(array[0], success: { (deviceScan) in
            print("--barcode zebra conect ID-- \(String(deviceScan.id)) name : \(String(deviceScan.name))")
        }) { (err) in

            print( "--Barcode zebra err-- \(String(err.description))")
            if (err.description == SCANNER_ERR_CONNECTED.description || err.description == SCANNER_ERR_CONNECTING.description){
            }else{
            }
        }
    }



    @IBAction func onBackgroundViewTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction private func onEnterButtonClicked(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        onEnter?()
    }


    @IBAction private func onFristButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        onFristButton?()
    }

    @IBAction private func onSencodeButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        onSencodeButton?(tfInput.text!)
    }


    @IBAction private func onCloseClicked(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }



    //MARK: - reader --
//    override func onTriggerChanged(_ trigger: Bool) {
//        LogUtil.DLog(message: "trigger --- \(trigger)")
//        if trigger == true{
//            self.appDelegate.RFID.readTag()
//        }
//        else{
//            self.appDelegate.RFID.reader?.stop()
//
//        }
//    }
//
//
//    override func onTriggerReaderZebra(_ trigger: Bool){
//        LogUtil.DLog(message: "trigger --- \(trigger)")
//        let delayTime = DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//        }
//    }
//
//    override func isUseDataRFID() -> Bool {
//        return true
//    }
//
//    override func getReadeDataRFID(_ codeRFID: String, _ radioRFID: String) {
//        if (codeRFID != "") {
//            let itemCode:String = codeRFID.lowercased() //.substring(from: 4)
//            if (itemCode.count > 0) {
//                self.tfInput.text = itemCode
//                btnSencond.isEnabled = true
//                LogUtil.DLog(message: "------------------EDITITEMVIE -- infoitem \(itemCode)")
//            }
//        }
//    }
}
