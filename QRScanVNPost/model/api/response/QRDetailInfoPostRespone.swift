//
//  QRDetailInfoPostRespone.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/22.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import SwiftyJSON

class QRDetailInfoPostRespone: QRResponse {

    var infoItems : [DetailInfoItemData]!

    override func parser() {
        infoItems = [DetailInfoItemData]()
        let detailItemData = DetailInfoItemData()

        let responseJson = self.dataResponse as!JSON
        print("-000-- QRDetailInfoItemRespone  --- responseJson -- \(responseJson)")

        let responseJsonOrder = responseJson["order"]
        print("-1111-- QRDetailInfoItemRespone  --- responseJson -- \(responseJsonOrder)")

        if responseJsonOrder["id"].exists(){
            detailItemData.id = responseJsonOrder["id"].int!
        }

        if  responseJsonOrder["order_code"].exists() {
            detailItemData.order_code = responseJsonOrder["order_code"].string!
        }
        if   responseJsonOrder["to_name"].exists() {
            detailItemData.to_name = responseJsonOrder["to_name"].string!
        }
        if   responseJsonOrder["from_address"].exists() {
            detailItemData.from_address = responseJsonOrder["from_address"].string!
        }

        if responseJsonOrder["from_name"].exists() {
            detailItemData.from_name = responseJsonOrder["from_name"].string!
        }
        if responseJsonOrder["bar_code"].exists() {
            detailItemData.bar_code = responseJsonOrder["bar_code"].string!
        }
        if responseJsonOrder["qr_code"].exists() {
            detailItemData.qr_code = responseJsonOrder["qr_code"].string!
        }
        if responseJsonOrder["rfid_code"].exists() {
            detailItemData.rfid_code = responseJsonOrder["rfid_code"].string!
        }
        if responseJsonOrder["to_address"].exists() {
            detailItemData.to_address = responseJsonOrder["to_address"].string!
        }
        if responseJsonOrder["from_tel"].exists() {
            detailItemData.from_tel = responseJsonOrder["from_tel"].string!
        }
        if responseJsonOrder["to_tel"].exists() {
            detailItemData.to_tel = responseJsonOrder["to_tel"].string!
        }

        if responseJsonOrder["user_id"].exists() {
            detailItemData.user_id = responseJsonOrder["user_id"].int!
        }
        if responseJsonOrder["warehouse_id"].exists() {
            detailItemData.warehouse_id = responseJsonOrder["warehouse_id"].int!
        }
        if responseJsonOrder["status"].exists() {
            detailItemData.status = responseJsonOrder["status"].int!
        }

        if responseJsonOrder["product_type"].exists() {
            detailItemData.product_type = responseJsonOrder["product_type"].bool!
        }

        do {
            print("-000000----database  \(infoItems.count)")
            try dbQueue.inDatabase { db in
                try detailItemData.insert(db)
            }
        }catch let error {
            print("error.localizedDescription ----- \(error.localizedDescription)")
        }

    }



}
