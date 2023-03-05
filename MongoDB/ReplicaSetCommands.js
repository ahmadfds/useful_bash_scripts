// 1 - run mongod on all rs servers using this command:
// $ mongod --port 27017 --replSet rs-shard-01

// 2 - run this command on srv1 only
rs.initiate({
    _id: "rs-01", // replica set name
    version: 1,
    members: [
        { _id: 0, host : "mongodb-srv1:27017" },
        { _id: 0, host : "mongodb-srv2:27017" },
        { _id: 0, host : "mongodb-srv3:27017" }
    ]
})
