//
//  BarcodeScannerError.swift
//  Monistor
//
//  Created by lhvu on 2018/12/26.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import Foundation
public struct BarcodeScannerError {
    public var id: Int
    public var description: String
}

public func scannerError(_ errCode: Int) -> BarcodeScannerError {
    switch errCode {
    case 1:
        return BarcodeScannerError(id: 1, description: "Operation Failed.")
    case 2:
        return BarcodeScannerError(id: 2, description: "Scanner Not Available.")
    case 3:
        return BarcodeScannerError(id: 3, description: "Scanner Not Active.")
    case 4:
        return BarcodeScannerError(id: 4, description: "Parameter does not match.")
    case 5:
        return BarcodeScannerError(id: 5, description: "Response Timeout Error.")
    case 6:
        return BarcodeScannerError(id: 6, description: "Not Supported Operation.")
    case 7:
        return BarcodeScannerError(id: 7, description: "Scanner Not Supported Action.")
    default:
        return BarcodeScannerError(id: 1, description: "Operation Failed.")
    }
}


public let SCANNER_ERR_DEVICE_NOT_IN_PROCESS = BarcodeScannerError(id: 993, description: "Device is NOT working on any task")
public let SCANNER_ERR_DEVICE_IN_PROCESS = BarcodeScannerError(id: 994, description: "Device is already working on a task")
public let SCANNER_ERR_NO_DEVICE = BarcodeScannerError(id: 996, description: "No Device Available")
public let SCANNER_ERR_CONNECTING = BarcodeScannerError(id: 997, description: "(Dis)Connecting Device...")
public let SCANNER_ERR_CONNECTED = BarcodeScannerError(id: 998, description: "Already Connected Device.")
public let SCANNER_ERR_NOT_CONNECTED = BarcodeScannerError(id: 999, description: "No Connected Device.")








