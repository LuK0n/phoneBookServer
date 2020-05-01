import FluentMySQLDriver
import Fluent
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    app.databases.use(.mysql(
        hostname: "127.0.0.1",
        username: "root",
        password: "rootroot",
        database: "testDb",
        tlsConfiguration: nil
    ), as: .mysql)
    
    app.migrations.add(FieldMigration())
    app.migrations.add(RefMigration())
    
    try routes(app)

}
