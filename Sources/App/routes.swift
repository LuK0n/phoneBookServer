import Crypto
import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    // public routes
    let userController = UserController()
    app.post("users", use: userController.create)
    
    // basic / password auth protected routes
//    let basic = app.grouped(UserAuthenticator())
//    app.post("login", use: UserController.login)
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login", use: userController.login)
    
    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("getMeAuthenticated", use: userController.getMeAuthenticated)
    
    // bearer / token auth protected routes
//    let bearer = router.grouped(User.tokenAuthMiddleware())
    let contactController = ContactController()
    tokenProtected.get("contacts", use: contactController.index)
    tokenProtected.post("contacts", use: contactController.create)
//    app.delete("contacts", Contact.parameter, use: contactController.delete)
}
