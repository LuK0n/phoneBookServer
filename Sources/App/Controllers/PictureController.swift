//
//  PicutreController.swift
//  phoneBookServer
//
//  Created by Lukas Kontur on 4/18/20.
//

import Vapor
import FluentMySQLDriver

final class PictureController {
    func index(_ req: Request) throws -> EventLoopFuture<Picture> {
        let user = try req.auth.require(User.self)
        
        let contactRequest = try req.content.decode(ModifyContactRequest.self)
        
        return try Picture.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(\.$contact.$id == contactRequest.contactId)
            .first().unwrap(or: Abort(.badRequest))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Picture> {
        try req.auth.require(User.self)
        
        let createPictReq = try req.content.decode(CreatePictureRequest.self)
        
        let picture = Picture(url: URL(string: createPictReq.url)!, contactID: createPictReq.contactId)
        
        let pictures : EventLoopFuture<Picture?> = try Picture.query(on: req.db)
        .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
        .filter(\.$contact.$id == createPictReq.contactId)
        .first()
        
        return pictures.flatMap{ pict in
            if pict != nil {
                return picture.update(on: req.db).map {
                    return picture
                }
            } else {
                return picture.save(on: req.db).map {
                    return picture
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let deletePictReq = try req.content.decode(DeletePictureRequest.self)
        
        let pictureDeleteFuture = try Picture.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .filter(\.$id == deletePictReq.pictureId)
            .first().flatMap { pict -> EventLoopFuture<Void> in
                return pict?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        return pictureDeleteFuture.flatMapResult { resp -> Result<HTTPStatus, Error> in
            if resp is Error {
                return .failure(Abort(.notFound))
            } else {
                return .success(.ok)
            }
        }
        
    }
}

struct CreatePictureRequest : Content {
    var url: String
    var contactId: UUID
}

struct DeletePictureRequest : Content {
    var pictureId : UUID
}
