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

    /// Creates a new Contact for the auth'd user.
    func create(_ req: Request) throws -> EventLoopFuture<Contact> {

        
        // decode request content
        let contReq = try req.content.decode(CreateContactRequest.self)
        return try self.createContact(contReq, req)
    }
        
        
    func createContact(_ cont: CreateContactRequest, _ req: Request) throws -> EventLoopFuture<Contact> {
        
        let user = try req.auth.require(User.self)
        let contact = try Contact(name: cont.name, email: cont.email, phoneNumber: cont.phoneNumb , userID: user.requireID())
        return contact.save(on: req.db).map {
            return contact
        }
    }

    /// Deletes an existing contact for the auth'd user.
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        // fetch auth'd user
        let deleteRequest = try req.content.decode(DeleteContactRequest.self)
        let contactDeleteFuture = Contact.query(on: req.db).filter(\.$id == deleteRequest.contactId).first().flatMap { cont -> EventLoopFuture<Void> in
            return cont?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.noContent))
        }
        let addressesDeletedFuture = Address.query(on: req.db).filter(\.$contact.$id == deleteRequest.contactId).all().flatMap { addr -> EventLoopFuture<Void> in
            let deleteFuture = req.eventLoop.future()
            for address in addr {
                deleteFuture.and(address.delete(on: req.db))
            }
            return deleteFuture
        }
        let picturesDeleteFuture = Picture.query(on: req.db).filter(\.$contact.$id == deleteRequest.contactId).all().flatMap { pict -> EventLoopFuture<Void> in
            let deleteFuture = req.eventLoop.future()
            for picture in pict {
                deleteFuture.and(picture.delete(on: req.db))
            }
            return deleteFuture
            
        }
        
        return picturesDeleteFuture.flatMap {
            return addressesDeletedFuture.flatMap {
                return contactDeleteFuture.flatMap { cont -> EventLoopFuture<HTTPStatus> in
                    req.eventLoop.makeSucceededFuture(.ok)
                }
            }
        }
        
    }
}

// MARK: Content

/// Represents data required to create a new contact.
struct CreateContactRequest: Content {
    
    
    /// Contact name.
    var name: String
    
    /// Contact email
    var email: String
    
    /// Contact phone number
    var phoneNumb: Int
    
}

struct DeleteContactRequest: Content {
    
    /// Contact id.
    var contactId: UUID
    
}
