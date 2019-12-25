//
//  Utils.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/21.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SystemConfiguration


class Utils {

    static func localizableString(from key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }



    static func isEmptyObject(_ obj: Any) -> Bool {
        if (obj is NSNull) || ((obj as AnyObject).isEqual(NSNull())){
            return true
        }
        else if (obj is String) {
            let string: String? = (obj as? String)
            if (string?.characters.count ?? 0) == 0 || (string == "") || (string == "(null)") || (string == nil) || (string == "<null>") || (string == "null") || (string?.replacingOccurrences(of: " ", with: "") == "") {
                return true
            }
        }
        return false
    }

    static func isEmptyJson(json:JSON,key:String)->Bool{
        if json[key].exists() {

            //            if json[key].object != nil{
            //                return false
            //            } else {
            //                return true
            //            }
            if json[key].type == SwiftyJSON.Type.null {
                return true
            }
            return false
        } else {
            return true
        }
    }
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    static func dateNow(format:String)-> String!{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    static func convertDate(inputDate : String?,inPutFormat:String! ,outPutFormat:String!)->String!{
        let dateFormatter_in = DateFormatter()
        dateFormatter_in.dateFormat = inPutFormat
        let dateFormatter_out = DateFormatter()
        dateFormatter_out.dateFormat = outPutFormat
        if let date = dateFormatter_in.date(from: inputDate!) {
            return dateFormatter_out.string(from: date)
        } else {
            return ""
        }
    }
    static func convertStringToJSon(stringJson: String) -> JSON? {
        let data = stringJson.data(using: String.Encoding.utf8)
        do{
            let result:JSON = try JSON(data: data!);
            return result
        }catch{
            return nil
        }

    }

    static func replacingString(strReplace: String) -> String{
        return strReplace.replacingOccurrences(of: "\\", with: "")
    }



    static func adjustPcBits(currentPcBits: String, newEpcLengthInWords: Int32)->String {
        let wcount:Int32 = Int32((newEpcLengthInWords + 3)/4)
        let beforepc16 = Int32(currentPcBits, radix: 16)!
        let pc16 = (beforepc16 & 2047) | (wcount << 11)
        let hexPc16:String = String(pc16, radix: 16)
        return hexPc16.leftPadding(toLength: 4, withPad: "0")
    }

    // Example: 0c60->1 1460->2 1c60->3
    static func epcLengthInWords(pcBits: String)->Int {
        return Int(Int(pcBits, radix:16)! >> 11)
    }


}

// UI
func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

class SCREEN {
    static let WIDTH = UIScreen.main.bounds.width
    static let HEIGHT = UIScreen.main.bounds.height
}

struct RATIO {
    static let SCREEN_WIDTH               = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.WIDTH / 375.0)
    static let SCREEN_HEIGHT              = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.HEIGHT / 667.0)
    static let SCREEN                     = ((RATIO.SCREEN_WIDTH + RATIO.SCREEN_HEIGHT) / 2.0)
}

struct ScaleValue {
    static let SCREEN_WIDTH         = (DeviceType.IPAD ? 1.8 : (DeviceType.IPHONE_6 ? 1.174 : (DeviceType.IPHONE_6P ? 1.295 : 1.0)))
    static let SCREEN_HEIGHT        = (DeviceType.IPAD ? 2.4 : (DeviceType.IPHONE_6 ? 1.171 : (DeviceType.IPHONE_6P ? 1.293 : 1.0)))
    static let FONT                 = (DeviceType.IPAD ? 1.0 : (DeviceType.IPHONE_6P ? 1.27 : (DeviceType.IPHONE_6 ? 1.15 : 1.0)))
}

struct Screen {
    static let BOUNDS   = UIScreen.main.bounds
    static let WIDTH    = UIScreen.main.bounds.size.width
    static let HEIGHT   = UIScreen.main.bounds.size.height
    static let MAX      = max(Screen.WIDTH, Screen.HEIGHT)
    static let MIN      = min(Screen.WIDTH, Screen.HEIGHT)
}

struct DeviceType {
    static let IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX <  568.0
    static let IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 568.0
    static let IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 667.0
    static let IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && Screen.MAX == 736.0
    static let IPAD              = UIDevice.current.userInterfaceIdiom == .pad   && Screen.MAX == 1024.0
}





extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .compactMap { pattern ~= $0 ? Character($0) : nil })
    }
}
