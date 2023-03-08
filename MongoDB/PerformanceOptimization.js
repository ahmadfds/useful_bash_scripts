// The write concern option determines the number of replicas that must acknowledge a
// write operation before it is considered successful. A higher write concern can improve
// data durability, but can also increase write latency. You can set the write concern at
// the global level, database level, or individual write operation level. For example,
// the following command sets the write concern to "majority" at the database level:
db.runCommand({ setWriteConcern: { w: "majority" } })

// Set Global Default Write Concern
db.adminCommand({
    "setDefaultRWConcern" : 1,
    "defaultWriteConcern" : {
        "w" : 1 // "majority"
    }
})


// get default write/read concern
db.adminCommand({getDefaultRWConcern: 1});


// Journaling is a feature in MongoDB that ensures data durability by writing all write operations
// to a journal file before they are written to disk. Enabling journaling can improve data
// durability but can also increase write latency. You can enable journaling by setting the
// "journal" option in the MongoDB configuration file:
// storage:
//   journal:
//     enabled: true



// WiredTiger is the default storage engine in MongoDB 3.2 and later. WiredTiger uses a cache to
// store frequently accessed data and indexes. You can configure the cache size using the
// "wiredTiger.engineConfig.cacheSizeGB" option in the MongoDB configuration file. A larger cache
// can improve write performance by reducing the number of disk I/O operations:
// storage:
//   wiredTiger:
//     engineConfig:
//       cacheSizeGB: 4


// Max Incoming Connections: The maxIncomingConnections option determines the maximum number of
// incoming connections that MongoDB can accept. A higher value can improve write performance
// by allowing more write operations to be processed simultaneously. You can set the
// maxIncomingConnections option in the MongoDB configuration file:
// net:
//   maxIncomingConnections: 5000