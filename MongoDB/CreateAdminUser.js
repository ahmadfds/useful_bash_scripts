// > use admin
db.createUser(
  {
    user: "myUserAdmin",
    pwd: passwordPrompt(), // or cleartext password
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
  }
)

//####################################################################
//
// Start the mongod with access control enabled.
// If you start the mongod from the command line, add the --auth command line option:
//     mongod --auth --port 27017 --dbpath /var/lib/mongodb
//
// If you start the mongod using a configuration file, add the security.authorization configuration file setting:
//     security:
//         authorization: enabled
//
//
//####################################################################

// Start mongosh with the -u <username>, -p, and the --authenticationDatabase <database> command line options:
// > mongosh --port 27017  --authenticationDatabase "admin" -u "myUserAdmin" -p


