//
//  QuickScanRequest.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


public enum QRRequestName: String {
    case  GET_DETAIL_PRODUCT_ITEM = "order/view/%@"
    case  POST_ITEM_INFO_DETAIL = "order/updateStatus"
    case POST_EDIT = "order/edit/%@"

}
class QuickScanRequest: QRRequest {
    
    var viewController :UIViewController?
    var bodyJson: NSObject?

    override init(requestName: String, responseType: QRResponseType?) {
        super.init(requestName: requestName, responseType: responseType)
//            setHeader() // post
    }

    func setHeader(isSet:Bool = true) {

    }

    override func getDomain() -> String {
        return "https://smartocr.dev/api/"
    }


    override func getVersion() -> String {
        return ""
    }

    override func getPath() -> String? {
        return nil
    }

    override func getBodyPost() -> String {
        return ""
    }
}
