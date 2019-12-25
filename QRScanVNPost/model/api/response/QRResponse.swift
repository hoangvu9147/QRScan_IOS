//
//  QRResponse.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum QRResponseType: String {
    case json = "JSON"
    case text     = "TEXT"
    case xml    = "XML"
}
class QRResponse {
    var dataResponse: Any
    var responseType:QRResponseType

    var result_code = 0;
    var message = ""
    var detailError = ""

    required init(responseData:Any,responseType:QRResponseType) {
        self.dataResponse = responseData
        self.responseType = responseType
        parserCommon()
    }

    func toResponse<T:QRResponse>(clazz: T.Type)->T{
        let object:T = clazz.init(responseData: dataResponse, responseType: responseType)
        object.parser()
        return object
    }

    func parser() {
        
    }

    func parserCommon() {

        if responseType == .json {
            let responseJson:JSON = dataResponse as! JSON
            let responseJsonError = responseJson["error"]

            if responseJsonError["code"].exists(){
                result_code = Int(responseJsonError["code"].rawString()!)!
            }
        }
    }
}

