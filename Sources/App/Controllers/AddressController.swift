//
//  PicutreController.swift
//  phoneBookServer
//
//  Created by Lukas Kontur on 4/18/20.
//

import Vapor
import FluentMySQLDriver

final class AddressController {
    func index(_ req: Request) throws -> EventLoopFuture<Address> {
        let user = try req.auth.require(User.self)
        
        let contactRequest = try req.content.decode(ModifyContactRequest.self)
        
        return try Address.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(\.$contact.$id == contactRequest.contactId)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .first().unwrap(or: Abort(.badRequest))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Address> {
        try req.auth.require(User.self)
        
        let createAddrReq = try req.content.decode(CreateAddressRequest.self)
        
        let addresses : EventLoopFuture<Address?> = Address.query(on: req.db)
        .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
        .filter(\.$contact.$id == createAddrReq.contactId)
        .first()
        
        return addresses.flatMap{ addr in
            return Address.find(addr?.$id.wrappedValue!, on: req.db).flatMap { data in
                let addr = Address(street: createAddrReq.street, city: createAddrReq.city, zip: createAddrReq.zip, houseNr: createAddrReq.houseNr,contactId: createAddrReq.contactId)
                if let data = data {
                    data.street = createAddrReq.street
                    data.city = createAddrReq.city
                    data.zip = createAddrReq.zip
                    data.houseNr = createAddrReq.houseNr
                }
                    
                return (data ?? addr).save(on: req.db).map {
                    return (data ?? addr)
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<GenericResponse> {
        let user = try req.auth.require(User.self)
        let deleteAddrReq = try req.content.decode(DeleteAddressRequest.self)
        
        let addressDeleteFuture = try Address.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .filter(\.$id == deleteAddrReq.addressId)
            .first().flatMap { pict -> EventLoopFuture<Void> in
                return pict?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        return addressDeleteFuture.flatMapResult { resp -> Result<GenericResponse, Error> in
            if resp is Error {
                return Result(catching: {GenericResponse(statusCode: 400)})
            } else {
                return Result(catching: {GenericResponse(statusCode: 200)})
            }
        }
        
    }
}
