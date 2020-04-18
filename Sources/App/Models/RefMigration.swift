//
//  File.swift
//
//
//  Created by Lukas Kontur on 4/16/20.
//

import Foundation
import Fluent

class RefMigration : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let totalSchemas = database.schema(Contact.schema)
            .field("userId", .uuid, .required, .references(User.schema, "id"))
            .update()
        
        totalSchemas.and(database.schema(Address.schema)
            .field("contactId", .uuid, .required, .references(Contact.schema, "id"))
            .update())
        
        totalSchemas.and(database.schema(Picture.schema)
            .field("contactId", .uuid, .required, .references(Contact.schema, "id"))
            .update())
        
        totalSchemas.and(database.schema(UserToken.schema)
            .field("userId", .uuid, .required, .references("users", "id"))
            .update())
        
        return totalSchemas
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        let totalSchemas = database.schema(Contact.schema)
            .deleteField("userId")
            .update()
        
        totalSchemas.and(database.schema(Address.schema)
            .deleteField("contactId")
            .update())
        
        totalSchemas.and(database.schema(Picture.schema)
            .deleteField("contactId")
            .update())
        
        totalSchemas.and(database.schema(UserToken.schema)
            .deleteField("userId")
            .update())
        return totalSchemas
    }
}
