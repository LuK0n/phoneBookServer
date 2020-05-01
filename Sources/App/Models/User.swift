import Fluent
import Vapor
import NIO

/// A registered user, capable of owning todo items.
final class User: Model, Content {
    init() {
        
    }
    
    static let schema: String = "users"
    /// User's unique identifier.
    /// Can be `nil` if the user has not been saved yet.
    @ID(key: .id)
    var id: UUID?
    
    /// User's full name.
    @Field(key: "name")
    var name: String
    
    /// User's email address.
    @Field(key:"email")
    var email: String
    
    /// BCrypt hash of the user's password.
    @Field(key:"passwordHash")
    var passwordHash: String
    
    /// Creates a new `User`.
    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
    
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

final class GenericResponse : Content {
    var statusCode : Int
    
    init(statusCode : Int) {
        self.statusCode = statusCode
    }
}

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
