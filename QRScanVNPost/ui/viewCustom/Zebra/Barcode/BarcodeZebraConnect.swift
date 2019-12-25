//
//  BarcodeZebraConnect.swift
//  Monistor
//
//  Created by lhvu on 2018/12/26.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import UIKit

public typealias BarcodeScannerOnErrorHandler = (_ status: BarcodeScannerError) -> ()
public typealias BarcodeScannerOnSimpleHandler = () -> ()
public typealias BarcodeScannerOnListHandler = (_ list: [BarcodeScannerDevice]) -> ()
public typealias BarcodeScannerOnConnectHandler = (_ device: BarcodeScannerDevice) -> ()
public typealias BarcodeScannerOnReadHandler = (_ barcode: String) -> ()

class BarcodeZebraConnect: NSObject, ISbtSdkApiDelegate {

    var onStart: (() ->())?
    var onComplete: ((_ isConnected: Bool) ->())?
    var onDisconnect: (() ->())?
   var requestConnect = false
    
    var readerInstance : ISbtSdkApi
    var dateFormatter : DateFormatter
    var isConnected : Bool = false
    var isWorking : Bool = false
    var isFinding : Bool = false

    @objc dynamic var deviceList : NSMutableArray = NSMutableArray()
    var deviceListPointer : AutoreleasingUnsafeMutablePointer<NSMutableArray?>
    @objc dynamic var message:NSString = NSString()
    var messagePointer:AutoreleasingUnsafeMutablePointer<NSString?>
    @objc dynamic var execMessage:NSMutableString = NSMutableString()
    var execMessagePointer:AutoreleasingUnsafeMutablePointer<NSMutableString?>
    var connectedDevice : BarcodeScannerDevice?

    var onConnectHandler: BarcodeScannerOnConnectHandler?
    var onDisconnectHandler: BarcodeScannerOnSimpleHandler?
    var onReadBarcodeHandler: BarcodeScannerOnReadHandler?

    override init() {
        readerInstance =  SbtSdkFactory.createSbtSdkApiInstance()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        deviceListPointer = AutoreleasingUnsafeMutablePointer<NSMutableArray?>.init(&deviceList)
        messagePointer = AutoreleasingUnsafeMutablePointer<NSString?>.init(&message)
        execMessagePointer = AutoreleasingUnsafeMutablePointer<NSMutableString?>.init(&execMessage)

        super.init()
        readerInstance.sbtSetDelegate(self)
        readerInstance.sbtEnableAvailableScannersDetection(true)
        readerInstance.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL))
        readerInstance.sbtSubsribe(forEvents: (Int32(SBT_EVENT_BARCODE) | Int32(SBT_EVENT_SCANNER_APPEARANCE) | Int32(SBT_EVENT_SCANNER_DISAPPEARANCE) | Int32(SBT_EVENT_SESSION_ESTABLISHMENT) | Int32(SBT_EVENT_SESSION_TERMINATION)))
    }

    func getReaderList(_ success: BarcodeScannerOnListHandler, failure: BarcodeScannerOnErrorHandler) {
        let result = readerInstance.sbtGetAvailableScannersList(deviceListPointer)
        guard result == SBT_RESULT_SUCCESS else {
            failure(scannerError(Int(result.rawValue)))
            return
        }
        var array: [BarcodeScannerDevice] = []
        for device in deviceList {
            if let rawDevice = device as? SbtScannerInfo {
                array.append(BarcodeScannerDevice(id: rawDevice.getScannerID(), name: rawDevice.getScannerName()))
            }
        }
        success(array)
    }

    func fastGetReaderList(_ success: BarcodeScannerOnListHandler, failure: BarcodeScannerOnErrorHandler) {
        var array: [BarcodeScannerDevice] = []
        for device in deviceList {
            if let rawDevice = device as? SbtScannerInfo {
                array.append(BarcodeScannerDevice(id: rawDevice.getScannerID(), name: rawDevice.getScannerName()))
            }
        }
        success(array)
    }

    func connect(_ device: BarcodeScannerDevice, success: @escaping BarcodeScannerOnConnectHandler, failure: BarcodeScannerOnErrorHandler) {

        onStart?()
        requestConnect = true
        if isConnected {
            failure(SCANNER_ERR_CONNECTED)
            return
        } else if isWorking{
            failure(SCANNER_ERR_CONNECTING)
            return
        }
        isWorking = true
        onConnectHandler = success
        let result = readerInstance.sbtEstablishCommunicationSession(device.id)
        if result != SBT_RESULT_SUCCESS {
            isWorking = false
            failure(scannerError(Int(result.rawValue)))
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.requestConnect {
                print("RFID: end request Connect RFID")
//                self.onComplete!(self.isConnected)
            }
        }

    }

    func disconnect(_ success: @escaping BarcodeScannerOnSimpleHandler, failure: BarcodeScannerOnErrorHandler) {
         requestConnect = false

        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(SCANNER_ERR_NOT_CONNECTED)
            return
        }
        isWorking = true
        if isFinding {
            let result2 = readerInstance.sbtExecuteCommand(Int32(SBT_DEVICE_SCAN_DISABLE), aInXML: "<inArgs><scannerID>\(Int(device.id))</scannerID></inArgs>", aOutXML: execMessagePointer, forScanner: device.id)

            if result2 != SBT_RESULT_SUCCESS {
                isWorking = false
                failure(scannerError(Int(result2.rawValue)))
                return
            }
        }

        onDisconnectHandler = success
        let result = readerInstance.sbtTerminateCommunicationSession(device.id)
        if result != SBT_RESULT_SUCCESS {
            isWorking = false
            failure(scannerError(Int(result.rawValue)))
        }

//        self.onComplete!(isConnected)

    }

    func startReadBarcode(_ onBarcode: @escaping BarcodeScannerOnReadHandler, success: BarcodeScannerOnSimpleHandler, failure: BarcodeScannerOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(SCANNER_ERR_NOT_CONNECTED)
            return
        }
        guard !isFinding else {
            failure(SCANNER_ERR_DEVICE_IN_PROCESS)
            return
        }
        let result = readerInstance.sbtExecuteCommand(Int32(SBT_DEVICE_SCAN_ENABLE), aInXML: "<inArgs><scannerID>\(Int(device.id))</scannerID></inArgs>", aOutXML: execMessagePointer, forScanner: device.id)
        if result != SBT_RESULT_SUCCESS {
            failure(scannerError(Int(result.rawValue)))
        } else {
            isFinding = true
            onReadBarcodeHandler = onBarcode
            success()
        }

    }


    func stopReadBarcode(_ success: BarcodeScannerOnSimpleHandler, failure: BarcodeScannerOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(SCANNER_ERR_NOT_CONNECTED)
            return
        }
        guard isFinding else {
            failure(SCANNER_ERR_DEVICE_NOT_IN_PROCESS)
            return
        }
        onReadBarcodeHandler = nil
        let result = readerInstance.sbtExecuteCommand(Int32(SBT_DEVICE_SCAN_DISABLE), aInXML: "<inArgs><scannerID>\(Int(device.id))</scannerID></inArgs>", aOutXML: execMessagePointer, forScanner: device.id)
        if result != SBT_RESULT_SUCCESS {
            failure(scannerError(Int(result.rawValue)))
        } else {
            isFinding = false
            onReadBarcodeHandler = nil
            success()
        }
    }



    func forceStop() {
        guard let device = connectedDevice else {
            isConnected = false
            isWorking = false
            isFinding = false
            onReadBarcodeHandler = nil
            return
        }
        readerInstance.sbtExecuteCommand(Int32(SBT_DEVICE_SCAN_DISABLE), aInXML: "<inArgs><scannerID>\(Int(device.id))</scannerID></inArgs>", aOutXML: execMessagePointer, forScanner: device.id)
        isConnected = false
        isWorking = false
        isFinding = false
        onReadBarcodeHandler = nil
    }

    func checkActiveConnection() -> BarcodeScannerError? {
        if isWorking {
            return(SCANNER_ERR_CONNECTING)
        } else if !isConnected {
            return(SCANNER_ERR_NOT_CONNECTED)
        }
        return nil
    }

    // Volume
    func setBeepVolumeBarcode(_ device: BarcodeScannerDevice,_ index : Int){
        var value = -1
        var attr_id: Int = -1

        attr_id = Int(RMD_ATTR_BEEPER_VOLUME)
        if (index == 0){
            value = Int(RMD_ATTR_VALUE_BEEPER_VOLUME_LOW)
        }else if (index == 1){
            value = Int(RMD_ATTR_VALUE_BEEPER_VOLUME_MEDIUM)
        }else{
            value = Int(RMD_ATTR_VALUE_BEEPER_VOLUME_HIGH)
        }

        let in_xml = "<inArgs><scannerID>\(device.id)</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>\(attr_id)</id><datatype>B</datatype><value>\(value)</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>"
        readerInstance.sbtExecuteCommand(Int32(SBT_RSM_ATTR_SET), aInXML: in_xml, aOutXML: execMessagePointer, forScanner: device.id)
    }

    func getBeepVolumeBarcode(_ device: BarcodeScannerDevice) -> Int{

        var in_xml = "<inArgs><scannerID>\(device.id)</scannerID><cmdArgs><arg-xml><attrib_list>\(Int(RMD_ATTR_BEEPER_VOLUME)),\(Int(RMD_ATTR_BEEPER_FREQUENCY))</attrib_list></arg-xml></cmdArgs></inArgs>"
        var result = ""
        let res = readerInstance.sbtExecuteCommand(Int32(SBT_RSM_ATTR_GET), aInXML: in_xml, aOutXML: execMessagePointer, forScanner: device.id)

        var res_str = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var tmp = "<attrib_list><attribute>"
        var range: NSRange = (res_str as NSString).range(of: tmp)
        var range2: NSRange?
//        if (range.location == NSNotFound) || (range.length != tmp.length()) {
//
//            break
//        }

        res_str = ((res_str as? NSString)?.substring(from: (range.location + range.length)))!

//         LogUtil.DLog(message: "--- DEBUG: --- res_str -- \(res_str)")

//        tmp = "</attribute></attrib_list>"
//        range = res_str.range(of: tmp)
//
//        range.length = res_str.length() - range.location
//
//        res_str = res_str.replacingCharacters(in: range, with: "")
//
//        var attrs = res_str.components(separatedBy: "</attribute><attribute>")
////
////        if attrs.count == 0 {
////            operationComplete()
////            break
////        }
//
//        var attr_str = ""
//
//        var attr_id: Int = 0
//        var attr_val: Int = 0
//        var row_id: Int = 0
//        var section_id: Int = 0
//
//        for pstr: String? in attrs {
//            attr_str = pstr
//            tmp = "<id>"
//            range = attr_str.range(of: tmp)
////            if (range.location != 0) || (range.length != tmp.length()) {
////                operationComplete()
////                break
////            }
//            attr_str = attr_str.replacingCharacters(in: range, with: "")
//
//            tmp = "</id>"
//
//            range = attr_str.range(of: tmp)
//
////            if (range.location == NSNotFound) || (range.length != tmp.length()) {
////                operationComplete()
////                break
////            }
//
//            range2.length = attr_str.length() - range.location
//            range2.location = range.location
//
//            var attr_id_str = attr_str.replacingCharacters(in: range2, with: "")
//
//            attr_id = Int(truncating: attr_id_str) ?? 0
//
//            range2.location = 0
//            range2.length = range.location + range.length
//
//            attr_str = attr_str.replacingCharacters(in: range2, with: "")
//
//            tmp = "<value>"
//            range = attr_str.range(of: tmp)
//            if (range.location == NSNotFound) || (range.length != tmp.length()) {
//                break
//            }
//            attr_str = (attr_str as? NSString)?.substring(from: (range.location + range.length))
//
//            tmp = "</value>"
//
//            range = attr_str.range(of: tmp)
//
//            if (range.location == NSNotFound) || (range.length != tmp.length()) {
//                break
//            }
//
//            range.length = attr_str.length() - range.location
//
//            attr_str = attr_str.replacingCharacters(in: range, with: "")
//
//            attr_val = attr_str
//
//            LogUtil.DLog(message: "--- DEBUG: attr_id -- \(attr_id)")
//            LogUtil.DLog(message: "--- DEBUG: attr_val -- \(attr_val)")
//        }

        return 0
    }


    // Delegate functions
    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Scanner \(availableScanner.getScannerName()) with ID:\(availableScanner.getScannerID()) Appeared.")

        let nameDevice : String! = availableScanner.getScannerName()
        deviceList.add(availableScanner)
        let cutTitleName : String!  = nameDevice.substring(to: 6)
        if cutTitleName == "CS4070" {
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.connectBarcodeZebra(idBarcode: Int(availableScanner.getScannerID()), nameBarcode: availableScanner.getScannerName())
            }
        }
    }

    //TODO: connect barcode ---
    func connectBarcodeZebra(idBarcode: Int , nameBarcode : String){
        let idBarcode = idBarcode
        let nameBarocde = nameBarcode
        var array: [BarcodeScannerDevice] = []

        array.append(BarcodeScannerDevice(id: Int32(idBarcode),name: nameBarocde))
//        LogUtil.DLog(message: "--- count array -- \(array.count)")
        self.connect(array[0], success: { (deviceScan) in
//            LogUtil.DLog(message: "--barcode zebra conect ID-- \(String(deviceScan.id)) name : \(String(deviceScan.name))")
        }) { (err) in

//            LogUtil.DLog(message: "--Barcode zebra err-- \(String(err.description))")
            if (err.description == SCANNER_ERR_CONNECTED.description || err.description == SCANNER_ERR_CONNECTING.description){
            }else{
            }
        }

    }


    func sbtEventScannerDisappeared(_ scannerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Scanner \(scannerID) Disappeared.")
        for i in 0..<deviceList.count {
            if let x = deviceList[i] as? SbtScannerInfo, x.getScannerID() == scannerID {
                deviceList.removeObject(at: i)
                break
            }
        }


        if let device = connectedDevice, device.id == scannerID {
            connectedDevice = nil
            isConnected = false
            isWorking = false
        }
    }

    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Communication Session Established with Scanner \(activeScanner.getScannerName()) with ID:\(activeScanner.getScannerID()).")
        onComplete?(isConnected)

        isConnected = true
        isWorking = false
        connectedDevice = BarcodeScannerDevice(id: activeScanner.getScannerID(), name: activeScanner.getScannerName())
        onConnectHandler?(BarcodeScannerDevice(id: activeScanner.getScannerID(), name: activeScanner.getScannerName()))
    }

    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Communication Session Terminated with Scanner \(scannerID).")
        isConnected = false
        isWorking = false
        onDisconnectHandler?()
    }

    func sbtEventBarcode(_ barcodeData: String!, barcodeType: Int32, fromScanner scannerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Read Barcode \(barcodeData) from Scanner \(scannerID).")
        onReadBarcodeHandler?(barcodeData)
    }

    func sbtEventBarcodeData(_ barcodeData: Data!, barcodeType: Int32, fromScanner scannerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [BarcodeReader] Read Barcode \(barcodeData) from Scanner \(scannerID).")
    }

    func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {
        // not used
    }

    func sbtEventImage(_ imageData: Data!, fromScanner scannerID: Int32) {
        // not used
    }

    func sbtEventVideo(_ videoFrame: Data!, fromScanner scannerID: Int32) {
        // not used
    }


}
