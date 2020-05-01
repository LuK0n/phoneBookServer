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
        
        return Picture.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(\.$contact.$id == contactRequest.contactId)
            .first().unwrap(or: Abort(.badRequest))
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Picture> {
        try req.auth.require(User.self)
        
        let createPictReq = try req.content.decode(CreatePictureRequest.self)
                
        let pictures : EventLoopFuture<Picture?> = Picture.query(on: req.db)
        .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
        .filter(\.$contact.$id == createPictReq.contactId)
        .first()
        
        return pictures.flatMap{ pict in
            return Picture.find(pict?.$id.wrappedValue!, on: req.db).flatMap { data in
                let pict = Picture(url: URL(string: createPictReq.url)!, contactID: createPictReq.contactId)
                if let data = data {
                    data.url = URL(string: createPictReq.url)!
                }
                return (data ?? pict).save(on: req.db).map {
                    return (data ?? pict)
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<GenericResponse> {
        let user = try req.auth.require(User.self)
        let deletePictReq = try req.content.decode(DeletePictureRequest.self)
        
        let pictureDeleteFuture = try Picture.query(on: req.db)
            .join(Contact.self, on: \Contact.$id == \._$id, method: .inner)
            .filter(Contact.self, \.$user.$id == user.requireID())
            .filter(\.$id == deletePictReq.pictureId)
            .first().flatMap { pict -> EventLoopFuture<Void> in
                return pict?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        return pictureDeleteFuture.flatMapResult { resp -> Result<GenericResponse, Error> in
            if resp is Error {
                return Result(catching: {GenericResponse(statusCode: 400)})
            } else {
                return Result(catching: {GenericResponse(statusCode: 200)})
            }
        }
        
    }
}
