//
//  RfidReaderZebraConnect.swift
//  Monistor
//
//  Created by lhvu on 2018/12/27.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import UIKit

public typealias RfidReaderOnErrorHandler = (_ status: RfidReaderError) -> ()
public typealias RfidReaderOnSimpleHandler = () -> ()
public typealias RfidReaderOnListHandler = (_ list: [RfidReaderDevice]) -> ()
public typealias RfidReaderOnConnectHandler = (_ device: RfidReaderDevice) -> ()
public typealias RfidReaderOnReadTagHandler = (_ tag: String) -> ()
public typealias RfidReaderOnTagLocationingHandler = (_ percent: Int) -> ()
public typealias RfidReaderOnAntennaLevelHandler = (_ percent: Int) -> ()
public typealias RfidReaderOnBatteryLevelHandler = (_ event: RfidBatteryEvent) -> ()
//public typealias RfidReaderOnReadeAddressBlutooth = (_ name: RfidReaderBluetoothAddress) -> ()
public typealias RfidReaderOnReadeAddressBlutooth = (_ address: String) -> ()

class RfidReaderZebraConnect: NSObject ,srfidISdkApiDelegate{

    var readerInstance : srfidISdkApi
    var dateFormatter : DateFormatter
    var isConnected : Bool = false
    var isWorking : Bool = false
    var isFinding : Bool = false

    @objc dynamic var deviceList : NSMutableArray = NSMutableArray()
    var deviceListPointer : AutoreleasingUnsafeMutablePointer<NSMutableArray?>
    @objc dynamic var antennaConf:srfidAntennaConfiguration = srfidAntennaConfiguration()
    var antennaConfPointer:AutoreleasingUnsafeMutablePointer<srfidAntennaConfiguration?>
//    var  beep : UnsafeMutablePointer<><#T##UnsafeMutablePointer<SRFID_BEEPERCONFIG>!#>
    @objc dynamic var readerCap:srfidReaderCapabilitiesInfo = srfidReaderCapabilitiesInfo()
    var readerCapPointer:AutoreleasingUnsafeMutablePointer<srfidReaderCapabilitiesInfo?>
    @objc dynamic var message:NSString? = NSString()
    //    var &message:AutoreleasingUnsafeMutablePointer<NSString?>

   var tagDataWrite:AutoreleasingUnsafeMutablePointer<srfidTagData?>
    
    let startConfig: srfidStartTriggerConfig
    let stopConfig: srfidStopTriggerConfig
    let reportConfig: srfidReportConfig
    let accessConfig: srfidAccessConfig
    let singulation:  srfidSingulationConfig
    let regulatory: srfidRegulatoryConfig

    var connectedDevice : RfidReaderDevice?
    var connectedDeviceInfo : srfidReaderInfo?

    var onConnectHandler: RfidReaderOnConnectHandler?
    var onDisconnectHandler: RfidReaderOnSimpleHandler?
    var onReadTagHandler: RfidReaderOnReadTagHandler?
    var onReadTagEpcHandler: RfidReaderOnReadTagHandler?
    var onTagLocationHandler: RfidReaderOnTagLocationingHandler?
    var onAntennaLevelHandler: RfidReaderOnAntennaLevelHandler?
    var onBatteryLevelHandler: RfidReaderOnBatteryLevelHandler?

    override init() {
        readerInstance = srfidSdkFactory.createRfidSdkApiInstance()
        readerInstance.srfidEnableAvailableReadersDetection(true)
        readerInstance.srfidEnableAutomaticSessionReestablishment(false)
        readerInstance.srfidSubsribe(forEvents: (Int32(SRFID_EVENT_READER_APPEARANCE) | Int32(SRFID_EVENT_READER_DISAPPEARANCE) | Int32(SRFID_EVENT_SESSION_ESTABLISHMENT) | Int32(SRFID_EVENT_SESSION_TERMINATION) | Int32(SRFID_EVENT_MASK_PROXIMITY) | Int32(SRFID_EVENT_MASK_READ) | Int32(SRFID_EVENT_MASK_STATUS) | Int32(SRFID_EVENT_MASK_BATTERY)))

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        deviceListPointer = AutoreleasingUnsafeMutablePointer<NSMutableArray?>.init(&deviceList)
        readerCapPointer = AutoreleasingUnsafeMutablePointer<srfidReaderCapabilitiesInfo?>.init(&readerCap)
        antennaConfPointer = AutoreleasingUnsafeMutablePointer<srfidAntennaConfiguration?>.init(&antennaConf)
        //        &message = AutoreleasingUnsafeMutablePointer<NSString?>.init(&message)
        tagDataWrite = AutoreleasingUnsafeMutablePointer<srfidTagData?>.init(&antennaConf)


        startConfig = srfidStartTriggerConfig()
        stopConfig = srfidStopTriggerConfig()
        reportConfig = srfidReportConfig()
        accessConfig = srfidAccessConfig()
        singulation = srfidSingulationConfig()
        regulatory  = srfidRegulatoryConfig()

        startConfig.setStartOnHandheldTrigger(true)
        startConfig.setTriggerType(SRFID_TRIGGERTYPE_PRESS)
        startConfig.setStartDelay(0)
        startConfig.setRepeatMonitoring(true)

        stopConfig.setStopOnHandheldTrigger(true)
        stopConfig.setTriggerType(SRFID_TRIGGERTYPE_RELEASE)
        stopConfig.setStopOnTimeout(false)
        stopConfig.setStopOnTagCount(false)
        stopConfig.setStopOnInventoryCount(false)
        stopConfig.setStopOnAccessCount(false)

        reportConfig.setIncPC(true)
        reportConfig.setIncPhase(true)
        reportConfig.setIncRSSI(true)
        reportConfig.setIncChannelIndex(true)
        reportConfig.setIncTagSeenCount(true)
        reportConfig.setIncFirstSeenTime(true)
        reportConfig.setIncLastSeenTime(true)

        accessConfig.setPower(270)
        accessConfig.setDoSelect(false)

        super.init()
        readerInstance.srfidSetDelegate(self)
    }

    func getAddressBluetooth(_ success: RfidReaderOnReadeAddressBlutooth, failure: RfidReaderOnErrorHandler) {
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        let result = readerInstance.srfidGetReaderCapabilitiesInfo(device.id, aReaderCapabilitiesInfo: readerCapPointer, aStatusMessage: &message)
        if result == SRFID_RESULT_SUCCESS {
            var addressBLE =  readerCap.getBDAddress()
            addressBLE = UtilityZebar.formatAddressBLE(addressBLE)
            success(addressBLE!)
        } else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        }
    }


    func getAntennaPower(_ success: RfidReaderOnAntennaLevelHandler, failure: RfidReaderOnErrorHandler) {
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        let result = readerInstance.srfidGetAntennaConfiguration(device.id, aAntennaConfiguration: antennaConfPointer, aStatusMessage: &message)
        if result == SRFID_RESULT_SUCCESS {
            success(Int(antennaConf.getPower()))
        } else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        }
    }



    func setAntennaPower(_ power: Int, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        var result = readerInstance.srfidGetReaderCapabilitiesInfo(device.id, aReaderCapabilitiesInfo: readerCapPointer, aStatusMessage: &message)

        guard result == SRFID_RESULT_SUCCESS else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }

        guard ((power >= readerCap.getMinPower()) && (power <= readerCap.getMaxPower())) else {
            failure(RFID_ERR_POWER_LEVEL_INVALID)
            return
        }

        result = readerInstance.srfidGetAntennaConfiguration(device.id, aAntennaConfiguration: antennaConfPointer, aStatusMessage: &message)

        guard result == SRFID_RESULT_SUCCESS else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }

        accessConfig.setPower(Int16(power))
        antennaConf.setPower(Int16(power))
        result = readerInstance.srfidSetAntennaConfiguration(device.id, aAntennaConfiguration: antennaConf, aStatusMessage: &message)

        guard result == SRFID_RESULT_SUCCESS else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }
        success()
    }

    func getAddressBluetoothReader(success: RfidReaderBluetoothAddress){
//        readerCap.getMinPower()

    }

    func getReaderList(_ success: RfidReaderOnListHandler, failure: RfidReaderOnErrorHandler) {
        let result = readerInstance.srfidGetAvailableReadersList(deviceListPointer)
        if result == SRFID_RESULT_SUCCESS {
            var array: [RfidReaderDevice] = []
            for device in deviceList {
                if let rawDevice = device as? srfidReaderInfo {
                    array.append(RfidReaderDevice(id: rawDevice.getReaderID(), name: rawDevice.getReaderName()))
                }
            }
            let result = readerInstance.srfidGetActiveReadersList(deviceListPointer)
            if result == SRFID_RESULT_SUCCESS {
                for device in deviceList {
                    if let rawDevice = device as? srfidReaderInfo {
                        array.append(RfidReaderDevice(id: rawDevice.getReaderID(), name: rawDevice.getReaderName()))
                    }
                }
                success(array)
            } else {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(result.rawValue)")
                failure(rfidError(Int(result.rawValue)))
            }
        } else {
            print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(result.rawValue)")
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func connect(_ device: RfidReaderDevice, success: @escaping RfidReaderOnConnectHandler, failure: RfidReaderOnErrorHandler) {
        if isConnected {
            failure(RFID_ERR_CONNECTED)
            return
        } else if isWorking{
            failure(RFID_ERR_CONNECTING)
            return
        }
        isWorking = true
        onConnectHandler = success
        let result = readerInstance.srfidEstablishCommunicationSession(device.id)
        if result != SRFID_RESULT_SUCCESS {
            isWorking = false
            print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(result.rawValue)")
            failure(rfidError(Int(result.rawValue)))
        }
        self.startReadTag()
    }

    func disconnect(_ success: @escaping RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        isWorking = true
        onDisconnectHandler = success
        if isFinding {
            let result2 = readerInstance.srfidStopOperation(device.id, aStatusMessage: &message)
            if result2 == SRFID_RESULT_SUCCESS {
                isFinding = false
            }else{
                isWorking = false
                if let msg = message {
                    print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
                }
                failure(rfidError(Int(result2.rawValue)))
            }
        }
        let result = readerInstance.srfidTerminateCommunicationSession(device.id)
        if result != SRFID_RESULT_SUCCESS {
            isWorking = false
            print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(result.rawValue)")
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func startReadTag(){ //(_ onRead: @escaping RfidReaderOnReadTagHandler, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if checkActiveConnection() != nil {
//            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
//            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard !isFinding else {
//            failure(RFID_ERR_DEVICE_IN_PROCESS)
            return
        }
        var result = readerInstance.srfidSetStartTriggerConfiguration(device.id, aStartTriggeConfig: startConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
//            failure(rfidError(Int(result.rawValue)))
            return
        }
        result = readerInstance.srfidSetStopTriggerConfiguration(device.id, aStopTriggeConfig: stopConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
//            failure(rfidError(Int(result.rawValue)))
            return
        }
//        onReadTagHandler = onRead
        result = readerInstance.srfidStartRapidRead(device.id, aReportConfig: reportConfig, aAccessConfig: accessConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
//            failure(rfidError(Int(result.rawValue)))
        } else {
            isFinding = true
//            success()
        }
    }

    func stopReadTag(_ success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard isFinding else {
            failure(RFID_ERR_DEVICE_NOT_IN_PROCESS)
            return
        }
        let result = readerInstance.srfidStopRapidRead(device.id, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            onReadTagHandler = nil
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        } else {
            isFinding = false
            success()
        }
    }

    func startReadTagEpc(_ onRead: @escaping RfidReaderOnReadTagHandler, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard !isFinding else {
            failure(RFID_ERR_DEVICE_IN_PROCESS)
            return
        }
        var result = readerInstance.srfidSetStartTriggerConfiguration(device.id, aStartTriggeConfig: startConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }
        result = readerInstance.srfidSetStopTriggerConfiguration(device.id, aStopTriggeConfig: stopConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }
        onReadTagEpcHandler = onRead
        result = readerInstance.srfidStartInventory(device.id, aMemoryBank: SRFID_MEMORYBANK_EPC, aReportConfig: reportConfig, aAccessConfig: accessConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        } else {
            isFinding = true
            success()
        }
    }

    func stopReadTagEpc(_ success:  RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard isFinding else {
            failure(RFID_ERR_DEVICE_NOT_IN_PROCESS)
            return
        }
        let result = readerInstance.srfidStopInventory(device.id, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            onReadTagEpcHandler = nil
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        } else {
            isFinding = false
            success()
        }
    }

    func startTagLocationing(_ tagId: String, handler: @escaping RfidReaderOnTagLocationingHandler, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard !isFinding else {
            failure(RFID_ERR_DEVICE_IN_PROCESS)
            return
        }
        var result = readerInstance.srfidSetStartTriggerConfiguration(device.id, aStartTriggeConfig: startConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }
        result = readerInstance.srfidSetStopTriggerConfiguration(device.id, aStopTriggeConfig: stopConfig, aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
            return
        }
        result = readerInstance.srfidStartTagLocationing(device.id, aTagEpcId: tagId, aStatusMessage: &message)
        if result == SRFID_RESULT_SUCCESS {
            onTagLocationHandler = handler
            isFinding = true
            success()
        } else {
            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func stopTagLocationing(_ success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {
        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        guard isFinding else {
            failure(RFID_ERR_DEVICE_NOT_IN_PROCESS)
            return
        }
        let result = readerInstance.srfidStopTagLocationing(device.id, aStatusMessage: &message)
        if result == SRFID_RESULT_SUCCESS {
            onTagLocationHandler = nil
            isFinding = false
            success()
        } else {
            if let msg = message{
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func setReadMode(_ isRfid: Bool, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {

        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        let result = readerInstance.srfidSetAttribute(device.id, attributeNumber: 1664, attributeValue:isRfid ? 0 : 1, attributeType:"B", aStatusMessage:&message)

        if result == SRFID_RESULT_SUCCESS {
            success()
        } else {
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func getBatteryStatus(_ onBattery: @escaping RfidReaderOnBatteryLevelHandler, success: RfidReaderOnSimpleHandler, failure: RfidReaderOnErrorHandler) {

        if let err = checkActiveConnection() {
            failure(err)
            return
        }
        guard let device = connectedDevice else {
            isConnected = false
            failure(RFID_ERR_NOT_CONNECTED)
            return
        }
        onBatteryLevelHandler = onBattery
        let result = readerInstance.srfidRequestBatteryStatus(device.id)
        if result == SRFID_RESULT_SUCCESS {
            success()
        } else {
            failure(rfidError(Int(result.rawValue)))
        }
    }

    func getConnectedReader() -> RfidReaderDevice? {
        return connectedDevice
    }

    func checkActiveConnection() -> RfidReaderError? {
        if isWorking {
            return(RFID_ERR_CONNECTING)
        } else if !isConnected {
            return(RFID_ERR_NOT_CONNECTED)
        }
        return nil
    }

    func forceStop() {
        guard let activeReader = connectedDevice else {
            isConnected = false
            isWorking = false
            isFinding = false
            return

        }
        readerInstance.srfidStopOperation(activeReader.id, aStatusMessage: &message)
        isConnected = false
        isWorking = false
        isFinding = false
    }

    // Delegate functions
    func srfidEventReaderAppeared(_ availableReader: srfidReaderInfo!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Reader \(String(describing: availableReader.getReaderName())) with ID:\(availableReader.getReaderID()) Appeared.")
//        LogUtil.DLog(message: "---  getMinPower \(readerCap.getMinPower())---  address \(readerCap.getBDAddress())")
        deviceList.add(availableReader)
    }

    func srfidEventReaderDisappeared(_ readerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Reader with ID:\(readerID) Disappeared.")
        if let device = connectedDevice, device.id == readerID {
            connectedDevice = nil
            isConnected = false
            isWorking = false
        }
    }

    func srfidEventCommunicationSessionEstablished(_ activeReader: srfidReaderInfo!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Communication Session Established with Reader \(activeReader.getReaderName()) with ID:\(activeReader.getReaderID()).")
        readerInstance.srfidEstablishAsciiConnection(activeReader.getReaderID(), aPassword: "qbssystem")
        let result = readerInstance.srfidStopOperation(activeReader.getReaderID(), aStatusMessage: &message)
        if result != SRFID_RESULT_SUCCESS {

            if let msg = message {
                print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] message: \(msg)")
            }
        }

        isConnected = true
        isWorking = false
        isFinding = false
        connectedDevice = RfidReaderDevice(id: activeReader.getReaderID(), name: activeReader.getReaderName())

        onConnectHandler?(RfidReaderDevice(id: activeReader.getReaderID(), name: activeReader.getReaderName()))
        onConnectHandler = nil
    }

    func srfidEventCommunicationSessionTerminated(_ readerID: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Communication Session Terminated with Reader with ID:\(readerID).")
        isConnected = false
        isWorking = false
        isFinding = false
        onDisconnectHandler?()
        onDisconnectHandler = nil
    }

    func srfidEventReadNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Tag Data is Read by Reader with ID:\(readerID), Tag ID:\(tagData.getTagId()). Tag Data:\(tagData.getMemoryBankData()). -- RSSI \(tagData.getPeakRSSI())")
        onReadTagHandler?(tagData.getTagId())
        onReadTagEpcHandler?(tagData.getMemoryBankData())

//        (UIApplication.shared.delegate as! AppDelegate).getReadCodeRfidReportZebra(tagData.getTagId()!, String(tagData.getPeakRSSI()))

    }

    func srfidEventStatusNotify(_ readerID: Int32, aEvent event: SRFID_EVENT_STATUS, aNotification notificationData: Any!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] EventStatus Reader ID:\(readerID), Event:\(event).")

//        (UIApplication.shared.delegate as! AppDelegate).onTriggerChangedReader(event.rawValue == 1 ? false : true )

    }

    func srfidEventProximityNotify(_ readerID: Int32, aProximityPercent proximityPercent: Int32) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] EventProximity Tag Located from Reader ID:\(readerID), Percent:\(proximityPercent)%.")
//        onTagLocationHandler?(Int(proximityPercent))
    }

    func srfidEventTriggerNotify(_ readerID: Int32, aTriggerEvent triggerEvent: SRFID_TRIGGEREVENT) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Reader ID:\(readerID), Event:\(triggerEvent).")
    }

    func srfidEventBatteryNotity(_ readerID: Int32, aBatteryEvent batteryEvent: srfidBatteryEvent!) {
        print("\(dateFormatter.string(from: Date())) DEBUG : [RfidReader] Battery Level for ID:\(readerID), Percent:\(batteryEvent.getPowerLevel())%.")
        if let device = connectedDevice {
            if (readerID == device.id) {
                onBatteryLevelHandler?(RfidBatteryEvent(level: Int(batteryEvent.getPowerLevel()), isCharging: batteryEvent.getIsCharging(), cause: batteryEvent.getCause() ))
            }
        }
    }

//    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
//        print("\(dateFormatter.string(from: Date())) DEBUG : [RFID] Scanner \(availableScanner.getScannerName()) with ID:\(availableScanner.getScannerID()) Appeared.")
//        deviceList.add(availableScanner)
//    }

    //MARK: Write tag

    func writeTag(_ readerID: Int32, tagID: String?, withOffset offset: Int16, withData data: String?, doBlockWrite blockWrite: Bool) {

        readerInstance.srfidWriteTag(readerID, aTagID: tagID, aAccessTagData: tagDataWrite, aMemoryBank: SRFID_MEMORYBANK_EPC, aOffset: offset, aData: data, aPassword: 3004, aDoBlockWrite: blockWrite, aStatusMessage:  &message)

    }


}
