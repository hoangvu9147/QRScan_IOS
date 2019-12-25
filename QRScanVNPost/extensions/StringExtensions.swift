//
//  extension.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/21.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {

        guard toLength > self.characters.count else { return self }

        let padding = String(repeating: withPad, count: toLength - self.characters.count)
        return padding + self
    }

    func isValidHexNumber() -> Bool {
        let hexaCharacters = CharacterSet(charactersIn: "ABCDEFabcdef0123456789")

        if (uppercased().trimmingCharacters(in: hexaCharacters) != "") {
            print("Invalid characters in string.")
            return false
        }
        return true
    }

    func isValidHexNumberBarcode() -> Bool {
        let hexaCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQWRSTUVXYZabcdefghijklmnopqwrstuvwxyz0123456789_-")

        if (uppercased().trimmingCharacters(in: hexaCharacters) != "") {
            print("Invalid characters in string.")
            return false
        }
        return true
    }


    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

}

extension String {

    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }


    var reformatDate: String {
        get {
            let dateFormaterFromString = DateFormatter()
            dateFormaterFromString.dateFormat = "yyyy-MM-dd hh:mm:ss"
            guard let date = dateFormaterFromString.date(from: self) else {
                return ""
            }

            let dateFormaterToString = DateFormatter()
            dateFormaterToString.dateFormat = "yyyy/MM/dd"
            return dateFormaterToString.string(from: date)
        }
    }

    var reformatDateDefault: String {
        get {
            let dateFormaterFromString = DateFormatter()
            dateFormaterFromString.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormaterFromString.date(from: self) else {
                return ""
            }
            let dateFormaterToString = DateFormatter()
            dateFormaterToString.dateFormat = "yyyy/MM/dd"
            return dateFormaterToString.string(from: date)
        }
    }

    func getDate(_ dateFormat: String = "yyyy-MM-dd hh:mm:ss") -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = dateFormat
        return dateFormater.date(from: self)
    }

    var json: JSON? {
        get {
            return Utils.convertStringToJSon(stringJson: self)
        }
    }

    var intArray: [Int] {
        get {
            return json?.array?.flatMap({$0.int}) ?? [Int]()
        }
    }

    var stringArray: [String] {
        get {
            return json?.array?.flatMap({$0.string}) ?? [String]()
        }
    }

    func getLabelString(locations: [String]) -> String {
        var result = ""
        for (index, location) in locations.enumerated() {
            if index == 0 {
                result.append(location)
            } else {
                result.append(" \(location)")
            }
        }
        return result
    }

    //----
    func localized(from key:String) -> String {
        let path = Bundle.main.path(forResource: key, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }




}

