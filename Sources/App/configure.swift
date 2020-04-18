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
    
    /// Configure migrations
//    var migrations = MigrationConfig()
//    migrations.add(migration: MainMigration.self, database: .mysql)
//    migrations.add(migration: ReferenceMigration.self, database: .mysql)
//    migrations.add(migration: NewUserMig.self, database: .mysql)
//    services.register(migrations)

}
