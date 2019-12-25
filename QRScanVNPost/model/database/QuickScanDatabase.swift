//
//  QuickScanDatabase.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/21.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import GRDB


struct QuickScanDatabase {

    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        dbQueue = try DatabaseQueue(path: path)

        // Use DatabaseMigrator to define the database schema
        try migrator.migrate(dbQueue)

        return dbQueue
    }


    /// The DatabaseMigrator that defines the database schema.
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()


        //create table categories
        migrator.registerMigration(DetailInfoItemData.databaseTableName) { db in
            // Create a table
            try db.create(table: DetailInfoItemData.databaseTableName) { t in
                t.column("_id", .integer).primaryKey(onConflict: nil, autoincrement: true)
                t.column("id", .integer).unique(onConflict:Database.ConflictResolution.replace)
                t.column("order_code", .text)
                t.column("from_name", .text)
                t.column("bar_code", .text)
                t.column("qr_code", .text)
                t.column("rfid_code", .text)
                t.column("to_name", .text)
                t.column("from_address", .text)
                t.column("to_address", .text)
                t.column("from_tel", .text)
                t.column("to_tel",.text)
                t.column("product_type",.boolean)
                t.column("user_id", .integer)
                t.column("warehouse_id", .integer)
                t.column("status",.integer)
            }
        }
        
        return migrator
    }
}
