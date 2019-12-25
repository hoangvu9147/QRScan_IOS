//
//  QRDetailInfoItemRespone.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/22.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import SwiftyJSON

class QRDetailInfoItemRespone: QRResponse {

    var infoItems : [DetailInfoItemData]!

    override func parser() {
        infoItems = [DetailInfoItemData]()

        let responseJson = self.dataResponse as!JSON
        print("--- QRDetailInfoItemRespone  --- responseJson -- \(responseJson)")

        if !Utils.isEmptyJson(json: responseJson, key: "order"){
            let arr_json = responseJson["order"].array
            print("--- arr_json count \(arr_json!.count)")

            for valueDetail in arr_json! {
                let detailItemData = DetailInfoItemData()

//                print( "--- 00000 \(valueDetail["order_code"].string!)")
//                print( "--- 111111 \(valueDetail["from_name"].string!)")
//                print("--- 222222 \(valueDetail["from_name"].string!)")

                if !Utils.isEmptyJson(json: valueDetail, key: "id") {
                    detailItemData.id = valueDetail["id"].int!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "order_code") {
                    detailItemData.order_code = valueDetail["order_code"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "from_name") {
                    detailItemData.from_name = valueDetail["from_name"].string!
                }
                //
                if !Utils.isEmptyJson(json: valueDetail, key: "to_name") {
                    detailItemData.to_name = valueDetail["to_name"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "from_address") {
                    detailItemData.from_address = valueDetail["from_address"].string!
                }

                if !Utils.isEmptyJson(json: valueDetail, key: "bar_code") {
                    detailItemData.bar_code = valueDetail["bar_code"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "qr_code") {
                    detailItemData.qr_code = valueDetail["qr_code"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "rfid_code") {
                    detailItemData.rfid_code = valueDetail["rfid_code"].string!
                }

                if !Utils.isEmptyJson(json: valueDetail, key: "to_address") {
                    detailItemData.to_address = valueDetail["to_address"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "from_tel") {
                    detailItemData.from_tel = valueDetail["from_tel"].string!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "to_tel") {
                    detailItemData.to_tel = valueDetail["to_tel"].string!
                }


                if !Utils.isEmptyJson(json: valueDetail, key: "user_id") {
                    detailItemData.user_id = valueDetail["user_id"].int!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "warehouse_id") {
                    detailItemData.warehouse_id = valueDetail["warehouse_id"].int!
                }
                if !Utils.isEmptyJson(json: valueDetail, key: "status") {
                    detailItemData.status = valueDetail["status"].int!
                }

                if !Utils.isEmptyJson(json: valueDetail, key: "product_type") {
                    detailItemData.product_type = valueDetail["product_type"].bool!
                }

                
//                infoItems.append(detailItemData)

                do {
                        print("-000000----database  \(infoItems.count)")
                    try dbQueue.inDatabase { db in
                        try detailItemData.insert(db)
                    }
                }catch let error {
                     print("error.localizedDescription ----- \(error.localizedDescription)")
                }

            }
            print("--- infoItems count \(infoItems.count)")
//
//            if infoItems.count > 0 {
//                DetailInfoItemData.save(infoItems: infoItems)
//            }

        }

    }


    func parserDataItemInfo( dataResponse: Any) -> Int{
        var count = 0
        let responseJson = dataResponse as! JSON
        if !Utils.isEmptyJson(json: responseJson, key: "order"){
            let arr_json = responseJson["order"].array
            count = (arr_json?.count)!
            print("--- arr_json count \(arr_json!.count)")
        }
        return count
    }



}

