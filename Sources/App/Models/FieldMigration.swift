//
//  File.swift
//  
//
//  Created by Lukas Kontur on 4/16/20.
//

import Foundation
import Fluent

class FieldMigration : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let totalSchemas = database.schema(Contact.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("phoneNumber", .int, .required)
            .create()
        
        totalSchemas.and(database.schema(Address.schema)
            .id()
            .field("street", .string, .required)
            .field("city", .string, .required)
            .field("zip", .string, .required)
            .field("houseNr", .string, .required)
            .create())
        
        totalSchemas.and(database.schema(Picture.schema)
            .id()
            .field("url", .string, .required)
            .create())
        
        totalSchemas.and(database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("passwordHash", .string, .required)
            .create())
        
        totalSchemas.and(database.schema(UserToken.schema)
            .id()
            .field("value", .string, .required)
            .unique(on: "value")
            .create())
        return totalSchemas
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        let totalSchemas = database.schema(Contact.schema).delete()
        totalSchemas.and(database.schema(Address.schema).delete())
        totalSchemas.and(database.schema(Picture.schema).delete())
        totalSchemas.and(database.schema(User.schema).delete())
        totalSchemas.and(database.schema(UserToken.schema).delete())
        return totalSchemas
    }
}
