import Crypto
import Vapor
import FluentMySQLDriver

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> EventLoopFuture<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.auth.require(User.self)

        // create new token for this user
        let token = try user.generateToken()

        // save and return token
        return token.save(on: req.db).map {token}
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws  -> EventLoopFuture<UserResponse>{
        // decode request content
        let userRequest = try req.content.decode(CreateUserRequest.self)
            // verify that passwords match
            guard userRequest.password == userRequest.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            // hash user's password using BCrypt
            let hash = try Bcrypt.hash(userRequest.password)
            // save new user
            let user =  User(name: userRequest.name, email: userRequest.email, passwordHash: hash)
        return user.save(on: req.db).flatMapThrowing {
            try UserResponse(id: user.requireID(), name: user.name, email: user.email)
        }
    }
    
    func removeToken(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let userTokenDeleteFuture = UserToken.query(on: req.db)
            .join(User.self, on: \UserToken.$user.$id == \User.$id, method: .inner)
            .filter(\.$user.$id == user.id!)
            .first().flatMap { token -> EventLoopFuture<Void> in
                return token?.delete(on: req.db) ?? req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        return userTokenDeleteFuture.flatMapResult { resp -> Result<HTTPStatus, Error> in
            if resp is Error {
                return .failure(Abort(.notFound))
            } else {
                return .success(.ok)
            }
        }
        
    }
    
    func getMeAuthenticated(_ req: Request) throws -> User {
        try req.auth.require(User.self)
        return try req.auth.require(User.self)
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct UserResponse: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: UUID
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
}

struct UserTokenDeleteReq: Content {
}
