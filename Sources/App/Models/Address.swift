import Fluent
import Vapor

final class Address: Model, Content {
    init() {
    }
    
    static let schema: String = "addresses"
    /// The unique identifier for this `Address`.
    @ID(key: .id)
    var id: UUID?

    /// A street of the 'Address'.
    @Field(key: "street")
    var street: String
    
    /// A city of the 'Address'.
    @Field(key: "city")
    var city: String
    
    /// A zip code of the 'Address'.
    @Field(key: "zip")
    var zip: String
    
    /// A house number of the 'Address'.
    @Field(key: "houseNr")
    var houseNr: String
    
    @Parent(key: "contactId")
    var contact: Contact

    /// Creates a new `Address`.
    init(id: UUID? = nil, street: String, city: String, zip: String, houseNr: String, contactId: Contact.IDValue) {
        self.id = id
        self.street = street
        self.city = city
        self.zip = zip
        self.houseNr = houseNr
        self.$contact.id = contactId
    }
}
