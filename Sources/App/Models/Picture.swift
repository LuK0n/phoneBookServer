//
//  Picture.swift
//  App
//
//  Created by Lukas Kontur on 3/8/20.
//

import Foundation
import Fluent
import Vapor

final class Picture: Model, Content {
    init() {
        
    }
    
    static let schema = "pictures"
    /// Id of 'Picture'
    @ID(key: .id)
    var id: UUID?
    
    /// Url of 'Picture'
    @Field(key: "url")
    var url: URL
    
    @Parent(key: "contactId")
    var contact: Contact
    
    
    /// Creates new picture
    init(id: UUID? = nil, url: URL, contactID: Contact.IDValue) {
        self.id = id
        self.url = url
        self.$contact.id = contactID
    }
}
