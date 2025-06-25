#!/bin/bash

# === Création des dossiers ===
mkdir -p data/configdb data/shard1 data/shard2 logs

# === Lancer les shards ===
mongod --shardsvr --replSet rsShard1 --port 27018 --dbpath ./data/shard1 --bind_ip localhost --fork --logpath ./logs/shard1.log
mongod --shardsvr --replSet rsShard2 --port 27019 --dbpath ./data/shard2 --bind_ip localhost --fork --logpath ./logs/shard2.log

# === Lancer le serveur de configuration ===
mongod --configsvr --replSet configReplSet --port 27017 --dbpath ./data/configdb --bind_ip localhost --fork --logpath ./logs/config.log

# Pause pour laisser les instances démarrer
sleep 5

# === Initialiser les replica sets ===
mongosh --port 27017 --eval 'rs.initiate({_id: "configReplSet", configsvr: true, members: [{_id: 0, host: "localhost:27017"}]})'
mongosh --port 27018 --eval 'rs.initiate({_id: "rsShard1", members: [{_id: 0, host: "localhost:27018"}]})'
mongosh --port 27019 --eval 'rs.initiate({_id: "rsShard2", members: [{_id: 0, host: "localhost:27019"}]})'

# === Lancer mongos ===
mongos --configdb configReplSet/localhost:27017 --bind_ip localhost --port 27020 --fork --logpath ./logs/mongos.log

# Pause pour la connexion
sleep 5

# === Configuration du sharding ===
mongosh --port 27020 --eval '
  sh.addShard("rsShard1/localhost:27018");
  sh.addShard("rsShard2/localhost:27019");
  sh.enableSharding("sharding_db");
  db = db.getSiblingDB("sharding_db");
  db.createCollection("realEstate");
  sh.shardCollection("sharding_db.realEstate", { city: 1 });
'

# === Importer les données ===
if [ -f ./data/real_estate.csv ]; then
  mongoimport --port 27020 --db sharding_db --collection realEstate --type csv --headerline --file ./data/real_estate.csv
else
  echo "⚠️ Fichier ./data/real_estate.csv introuvable !"
fi

# === Vérifications ===
mongosh --port 27020 --eval '
  sh.status();
  db = db.getSiblingDB("sharding_db");
  db.realEstate.getShardDistribution();
  printjson(db.realEstate.find().explain("executionStats"));
'

echo "✅ Cluster sharded MongoDB prêt."
