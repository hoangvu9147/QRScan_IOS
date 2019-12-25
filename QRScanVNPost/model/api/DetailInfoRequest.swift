//
//  DetailInfoRequest.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/21.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
class DetailInfoRequest : QuickScanRequest {

    override init(requestName: String, responseType: QRResponseType? = nil) {
        super.init(requestName: requestName, responseType: responseType)
         addHeaders(key: "Content-Type", value: "application/json")
    }

    func postStatusInfoItem(order_id: String,status: String ) -> QRRequest {
        addParam(key: "order_id", value: order_id)
        addParam(key: "status", value: status)
        return super.post()
    }


    func postEdittem(from_name: String,to_name: String,from_address: String,to_address: String,from_tel: String,to_tel: String,product_type: Int ) -> QRRequest {
        addParam(key: "from_name", value: from_name)
        addParam(key: "to_name", value: to_name)
        addParam(key: "from_address", value: from_address)
        addParam(key: "to_address", value: to_address)
        addParam(key: "from_tel", value: from_tel)
        addParam(key: "to_tel", value: to_tel)
        addParam(key: "product_type", value: product_type)
        return super.post()
    }


}
