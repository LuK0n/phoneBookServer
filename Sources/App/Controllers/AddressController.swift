//
//  PicutreController.swift
//  phoneBookServer
//
//  Created by Lukas Kontur on 4/18/20.
//

import Vapor
import FluentMySQLDriver

final class AddressController {
    func index(_ req: Request) throws -> EventLoopFuture<[Address]> {
        let user = try req.auth.require(User.self)
        
        let contactRequest = try req.content.decode(ModifyContactRequest.self)
        
        return try Address.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(\.$contact.$id == contactRequest.contactId)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Address> {
        try req.auth.require(User.self)
        
        let createAddrReq = try req.content.decode(CreateAddressRequest.self)
        
        let address = Address(street: createAddrReq.street, city: createAddrReq.city, zip: createAddrReq.zip, houseNr: createAddrReq.houseNr, contactId: createAddrReq.contactId)
        return address.save(on: req.db).map {
            return address
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let deleteAddrReq = try req.content.decode(DeleteAddressRequest.self)
        
        let addressDeleteFuture = try Address.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .filter(\.$id == deleteAddrReq.addressId)
            .first().flatMap { pict -> EventLoopFuture<Void> in
                return pict?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        return addressDeleteFuture.flatMapResult { resp -> Result<HTTPStatus, Error> in
            if resp is Error {
                return .failure(Abort(.notFound))
            } else {
                return .success(.ok)
            }
        }
        
    }
}

struct CreateAddressRequest : Content {
    var street: String
    var city: String
    var zip: String
    var houseNr: String
    var contactId: UUID
}

struct DeleteAddressRequest : Content {
    var addressId : UUID
}
