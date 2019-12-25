//
//  DetailInfoItemData.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/21.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import GRDB

final class DetailInfoItemData : Record {

    var _id: Int64?

    var id: Int
    var order_code: String
    var from_name: String
    var to_name: String
    var from_address: String
    var bar_code: String
    var qr_code: String
    var rfid_code: String
    var to_address: String
    var from_tel: String
    var to_tel : String
    var product_type : Bool
    var user_id : Int
    var warehouse_id : Int
    var status : Int



    override class var databaseTableName: String {
        return "detail_Info"
    }
    override init() {
        self.id = 0
        self.order_code = ""
        self.from_name = ""
        self.to_name = ""
        self.from_address = ""
        self.bar_code = ""
        self.qr_code  = ""
        self.rfid_code = ""
        self.to_address = ""
        self.from_tel = ""
        self.to_tel = ""
        self.product_type = false
        self.user_id = 0
        self.warehouse_id = 0
        self.status = 0

        super.init()
    }

    required init(row: Row) {
        _id = row["_id"]

        id = row["id"]
        order_code = row["order_code"]
        from_name = row["from_name"]
        to_name = row["to_name"]
        from_address = row["from_address"]
        bar_code = row["bar_code"]
        qr_code  = row["qr_code"]
        rfid_code = row["rfid_code"]
        to_address = row["to_address"]
        from_tel = row["from_tel"]
        to_tel = row["to_tel"]
        product_type = row["product_type"]
        user_id = row["user_id"]
        warehouse_id = row["warehouse_id"]
        status = row["status"]
        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container["_id"] = _id
        
        container["id"] = id
        container["order_code"] = order_code
        container["from_name"] = from_name
        container["to_name"] = to_name
        container["from_address"] = from_address
        container["bar_code"] = bar_code
        container["qr_code"] =  qr_code
        container["rfid_code"] =  rfid_code
        container["to_address"] = to_address
        container["from_tel"] = from_tel
        container["to_tel"] = to_tel
        container["product_type"] = product_type
        container["user_id"] = user_id
        container["warehouse_id"] = warehouse_id
        container["status"] = status
    }


    static func save(infoItems:[DetailInfoItemData]) {
        do {
            try dbQueue.inTransaction { db in
                for obj in infoItems {
                    try obj.insert(db)
                }
                return .commit
            }
        } catch {
            return
        }
    }


    static func getDetailById(id: Int) -> DetailInfoItemData? {
        return dbQueue.inDatabase {
            do {
                return try DetailInfoItemData.fetchOne($0,
                                                       sql: "SELECT * FROM \(DetailInfoItemData.databaseTableName) where id = ? ",
                    arguments: [id])
            } catch {
                return nil
            }
        }
    }

    static func getDetailByBarcodeID(bar_code: String) -> DetailInfoItemData? {
        let query = "SELECT * FROM \(DetailInfoItemData.databaseTableName) where qr_code = ?"
        print("query -- \(query)")

        return dbQueue.inDatabase {
            do {
                return try DetailInfoItemData.fetchOne($0,
                                                       sql: query,
                    arguments: [bar_code])
            } catch {
                return nil
            }
        }
    }


    static func getAll() -> [DetailInfoItemData]{
        return dbQueue.inDatabase {
            do {
                return try DetailInfoItemData.fetchAll($0)
            } catch {
                return [DetailInfoItemData]()
            }
        }
    }

    static func deleteBy(id: Int) {
        _ = dbQueue.inDatabase({
            try? DetailInfoItemData.fetchOne($0
                , sql: "delete from detail_Info where id = ?"
                , arguments: [id])
        })
    }


}
