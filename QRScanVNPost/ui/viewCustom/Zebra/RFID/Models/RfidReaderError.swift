//
//  RfidReaderError.swift
//  Monistor
//
//  Created by lhvu on 2018/12/27.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import Foundation
public struct RfidReaderError {
    public var id: Int
    public var description: String
}

public func rfidError(_ errCode: Int) -> RfidReaderError {
    switch errCode {
    case 1:
        return RfidReaderError(id: 1, description: "Operation Failed.")
    case 2:
        return RfidReaderError(id: 2, description: "Reader Not Available.")
    case 4:
        return RfidReaderError(id: 4, description: "Parameter does not match.")
    case 5:
        return RfidReaderError(id: 5, description: "Response Timeout Error.")
    case 6:
        return RfidReaderError(id: 6, description: "Not Supported Operation.")
    case 7:
        return RfidReaderError(id: 7, description: "Response From Reader Error.")
    case 8:
        return RfidReaderError(id: 8, description: "ASCII Password Error.")
    case 9:
        return RfidReaderError(id: 9, description: "ASCII Connection Required.")
    default:
        return RfidReaderError(id: 1, description: "Operation Failed.")
    }
}

public let RFID_ERR_DEVICE_NOT_IN_PROCESS = RfidReaderError(id: 993, description: "Device is NOT working on any task")
public let RFID_ERR_DEVICE_IN_PROCESS = RfidReaderError(id: 994, description: "Device is already working on a task")
public let RFID_ERR_POWER_LEVEL_INVALID = RfidReaderError(id: 995, description: "Power Level is Invalid")
public let RFID_ERR_NO_DEVICE = RfidReaderError(id: 996, description: "No Device Available")
public let RFID_ERR_CONNECTING = RfidReaderError(id: 997, description: "(Dis)Connecting Device...")
public let RFID_ERR_CONNECTED = RfidReaderError(id: 998, description: "Already Connected Device.")
public let RFID_ERR_NOT_CONNECTED = RfidReaderError(id: 999, description: "No Connected Device.")
