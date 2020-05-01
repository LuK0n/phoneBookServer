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
    bearerTokenProtected.delete("userToken", use: userController.removeToken)
    bearerTokenProtected.get("getMeAuthenticated", use: userController.getMeAuthenticated)
    
    let contactController = ContactController()
    bearerTokenProtected.get("contacts", use: contactController.index)
    bearerTokenProtected.post("contacts", use: contactController.create)
    bearerTokenProtected.post("contactsUpdate", use: contactController.contactUpdate)
    bearerTokenProtected.delete("contacts", use: contactController.delete)
    
    let pictureController = PictureController()
    bearerTokenProtected.post("pictures", use: pictureController.create)
    bearerTokenProtected.post("picturesGet", use: pictureController.index)
    bearerTokenProtected.delete("pictures", use: pictureController.delete)
    
    let addressController = AddressController()
    bearerTokenProtected.post("addresses", use: addressController.create)
    bearerTokenProtected.post("addressesGet", use: addressController.index)
    bearerTokenProtected.delete("addresses", use: addressController.delete)
}
