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
    func delete(_ req: Request) throws {
        // fetch auth'd user
        let addresses = Address.query(on: req.db)
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
