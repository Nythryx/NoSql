#!/bin/bash

# === Définition des ports ===
PORT1=27018
PORT2=27019
PORT3=27020
CONFIG_PORT=27017
MONGOS_PORT=27021

# === Création des dossiers ===
mkdir -p data/shard1 data/shard2 data/shard3 data/configdb

# === Démarrage des shards ===
mongod --port $PORT1 --dbpath data/shard1 --shardsvr --replSet rsShard1 --fork --logpath data/shard1.log
mongod --port $PORT2 --dbpath data/shard2 --shardsvr --replSet rsShard2 --fork --logpath data/shard2.log
mongod --port $PORT3 --dbpath data/shard3 --shardsvr --replSet rsShard3 --fork --logpath data/shard3.log

# === Démarrage du serveur de configuration ===
mongod --port $CONFIG_PORT --configsvr --replSet rsConfig --dbpath data/configdb --fork --logpath data/configdb.log

# === Initialisation des replica sets ===

# Config server
mongo --port $CONFIG_PORT --eval '
rs.initiate({
  _id: "rsConfig",
  configsvr: true,
  members: [{ _id: 0, host: "localhost:'$CONFIG_PORT'" }]
})'

sleep 5

# Shards
mongo --port $PORT1 --eval '
rs.initiate({
  _id: "rsShard1",
  members: [{ _id: 0, host: "localhost:'$PORT1'" }]
})'

mongo --port $PORT2 --eval '
rs.initiate({
  _id: "rsShard2",
  members: [{ _id: 0, host: "localhost:'$PORT2'" }]
})'

mongo --port $PORT3 --eval '
rs.initiate({
  _id: "rsShard3",
  members: [{ _id: 0, host: "localhost:'$PORT3'" }]
})'

sleep 5

# === Démarrage de mongos ===
mongos --configdb rsConfig/localhost:$CONFIG_PORT --port $MONGOS_PORT --fork --logpath mongos.log

sleep 5

# === Configuration du sharding via mongos ===
mongo --port $MONGOS_PORT --eval '
sh.addShard("rsShard1/localhost:'$PORT1'")
sh.addShard("rsShard2/localhost:'$PORT2'")
sh.addShard("rsShard3/localhost:'$PORT3'")
sh.enableSharding("realEstateDB")
sh.shardCollection("realEstateDB.realEstate", { propertyId: "hashed" })
'

# === Insertion de données test ===
mongo realEstateDB --port $MONGOS_PORT --eval '
for (let i = 0; i < 1000; i++) {
  db.realEstate.insert({ propertyId: i, name: "Maison" + i })
}
'

# === Vérification ===
mongo realEstateDB --port $MONGOS_PORT --eval '
sh.status()
db.realEstate.getShardDistribution()
db.realEstate.find().explain("executionStats")
'

echo "✅ Cluster MongoDB sharded configuré avec succès."
