//
//  Contact.swift
//  App
//
//  Created by Lukas Kontur on 3/8/20.
//

import Fluent
import Vapor

final class Contact : Model, Content {
    init() {
    }
    
    static let schema: String = "contacts"
    /// Contact's unique identifier.
    /// Can be `nil` if the user has not been saved yet.
    @ID(key: .id)
    var id: UUID?
    
    /// Contact's full name.
    @Field(key: "name")
    var name: String
    
    /// Contact's email address.
    @Field(key: "email")
    var email: String
    
    /// Contact's phone number.
    @Field(key: "phoneNumber")
    var phoneNumber: Int
    
    /// Relation to user
    @Parent(key: "userId")
    var user: User
    
    /// Creates a new `Contact`.
    init(id: UUID? = nil, name: String, email: String, phoneNumber: Int, userID: User.IDValue) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.$user.id = userID
    }
}

struct ModifyContactRequest: Content {
    
    /// Contact id.
    var contactId: UUID
    
}
