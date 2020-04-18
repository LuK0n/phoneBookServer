import Crypto
import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    // public routes
    let userController = UserController()
    app.post("users", use: userController.create)
    
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login", use: userController.login)
    
    let bearerTokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("getMeAuthenticated", use: userController.getMeAuthenticated)
    
    let contactController = ContactController()
    tokenProtected.get("contacts", use: contactController.index)
    tokenProtected.post("contacts", use: contactController.create)
    tokenProtected.delete("contacts", use: contactController.delete)
}
