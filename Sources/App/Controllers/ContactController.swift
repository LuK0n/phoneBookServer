import Vapor
import FluentMySQLDriver

/// Contact controller.
final class ContactController {
    /// Returns a list of all Contacts for the auth'd user.
    func index(_ req: Request) throws -> EventLoopFuture<[Contact]> {
        
        let user = try req.auth.require(User.self)
        
        // query all contact's belonging to user
        return Contact.query(on: req.db)
            .join(User.self, on: \Contact.$user.$id == \User.$id, method: .inner)
            .filter(\.$user.$id == user.id!)
            .all()
    }
    
    func contactUpdate(_ req: Request) throws -> EventLoopFuture<Contact> {
        let user = try req.auth.require(User.self)
        
        let contReq = try req.content.decode(UpdateContactRequest.self)
        
        let contacts : EventLoopFuture<Contact?> = Contact.query(on: req.db)
        .filter(\._$id == contReq.id)
        .first()
        
        return contacts.flatMap{ cont in
            return Contact.find(cont?.$id.wrappedValue!, on: req.db).flatMap { data in
                    data?.name = contReq.name
                    data?.email = contReq.email
                    data?.phoneNumber = contReq.phoneNumber
                return data!.update(on: req.db).map {
                    return data!
                }
            }
        }
    }

    /// Creates a new Contact for the auth'd user.
    func create(_ req: Request) throws -> EventLoopFuture<Contact> {
        let user = try req.auth.require(User.self)
        
        // decode request content
        let contReq = try req.content.decode(CreateContactRequest.self)
        return try self.createContact(contReq, req, user)
    }
        
        
    func createContact(_ cont: CreateContactRequest, _ req: Request, _ user: User) throws -> EventLoopFuture<Contact> {
        
        let contact = try Contact(name: cont.name, email: cont.email, phoneNumber: cont.phoneNumber , userID: user.requireID())
        return contact.save(on: req.db).map {
            return contact
        }
    }

    /// Deletes an existing contact for the auth'd user.
    func delete(_ req: Request) throws -> EventLoopFuture<GenericResponse> {
        // fetch auth'd user
        let deleteRequest = try req.content.decode(ModifyContactRequest.self)
        let contactDeleteFuture = Contact.query(on: req.db).filter(\.$id == deleteRequest.contactId).first().flatMap { cont -> EventLoopFuture<Void> in
            return cont?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        let addressesDeletedFuture = Address.query(on: req.db).filter(\.$contact.$id == deleteRequest.contactId).first().flatMap { addr -> EventLoopFuture<Void> in
            return addr?.delete(on: req.db) ?? req.eventLoop.makeSucceededFuture(())
        }
        let picturesDeleteFuture = Picture.query(on: req.db).filter(\.$contact.$id == deleteRequest.contactId).first().flatMap { pict -> EventLoopFuture<Void> in
            return pict?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.badRequest))
            
        }
        
        return picturesDeleteFuture.flatMap {
            return addressesDeletedFuture.flatMap {
                return contactDeleteFuture.flatMapResult { res -> Result<GenericResponse, Error> in
                    if res is Error {
                        return Result(catching: {GenericResponse(statusCode: 400)})
                    } else {
                        return Result(catching: {GenericResponse(statusCode: 200)})
                    }
                }
            }
        }
        
    }
}
