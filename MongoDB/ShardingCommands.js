// 1- run mongo db on each shard replicaset this way:
// $ mongod --port 27017 --shardsvr --replSet rs-shard-01


// 2- run configuration server command:
// $ mongod --port 27017 --configsvr --replSet rs-config-server
// then insid configserver 1 init replica set this way:
rs.initiate({
    _id: "rs-config-server",
    configsvr: true,
    version: 1,
    members: [
        { _id: 0, host : 'mongodb-config-01:27017' },
        { _id: 1, host : 'mongodb-config-02:27017' },
        { _id: 2, host : 'mongodb-config-03:27017' }
    ]
})


// 3- run server router command:
// $ mongos --port 27017 --configdb rs-config-server/mongodb-config-01:27017,mongodb-config-02:27017,mongodb-config-03:27017 --bind_ip_all
// then inside mongos add the shards:
sh.addShard("rs-shard-01/mongodb-shard-01:27017")
sh.addShard("rs-shard-02/mongodb-shard-02:27017")
sh.addShard("rs-shard-03/mongodb-shard-03:27017")


// Other commands:
sh.enableSharding('dbname') // enable db sharding
sh.shardCollection("dbname.collection", {hashKey: "hashed"}, { chunkSize: 16 }) // enable collection sharding
sh.getShardedDataDistribution()
db.collection.drop({sharded:true})