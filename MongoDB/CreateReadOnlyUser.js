// > use admin
db.createUser(
  {
    user: "readonlyuser",
    pwd: passwordPrompt(), // or cleartext password
    roles: [ { role: "read", db: "database name" } ]
  }
)