#!/bin/bash

# Attention : Ce script suppose que mongod et mongosh sont installés et 
# dans le PATH, et que on est sous l'environnement Linux

# 1. Création des dossiers de données
BASE_DIR=~/mongo-replica
rm -rf $BASE_DIR
mkdir -p $BASE_DIR/data/db1 $BASE_DIR/data/db2 $BASE_DIR/data/db3

# 2. Fichier de config avec réplication
CONF_FILE=$BASE_DIR/mongod.conf
cat > $CONF_FILE <<EOF
replication:
  replSetName: "rs0"
EOF

# 3. Démarrage des 3 instances mongod
mongod --port 27017 --dbpath $BASE_DIR/data/db1 --replSet rs0 --bind_ip localhost --fork --logpath $BASE_DIR/data/db1/mongod.log --config $CONF_FILE
mongod --port 27018 --dbpath $BASE_DIR/data/db2 --replSet rs0 --bind_ip localhost --fork --logpath $BASE_DIR/data/db2/mongod.log --config $CONF_FILE
mongod --port 27019 --dbpath $BASE_DIR/data/db3 --replSet rs0 --bind_ip localhost --fork --logpath $BASE_DIR/data/db3/mongod.log --config $CONF_FILE

sleep 5 # attendre que les serveurs soient prêts

# 4. Initialiser le replica set
mongosh --port 27017 --eval '
rs.initiate({
  _id: "rs0",
  members: [
    {_id: 0, host: "localhost:27017"},
    {_id: 1, host: "localhost:27018"},
    {_id: 2, host: "localhost:27019"}
  ]
});
rs.status();
'

# 5. Créer la base et insérer les documents
mongosh --port 27017 --eval '
use GameOfThrones;
db.characters.insertMany([
  { name: "Jon Snow", age: 25, house: "Stark" },
  { name: "Daenerys Targaryen", age: 23, house: "Targaryen" },
  { name: "Tyrion Lannister", age: 30, house: "Lannister" }
]);
db.characters.find().pretty();
'

# 6. Vérifier la réplication sur secondaire (port 27018)
echo "Données sur le secondaire (27018) :"
mongosh --port 27018 --eval '
use GameOfThrones;
db.characters.find().pretty();
'

# 7. Shutdown propre des instances
mongosh --port 27017 --eval 'db.getSiblingDB("admin").shutdownServer()' &>/dev/null
mongosh --port 27018 --eval 'db.getSiblingDB("admin").shutdownServer()' &>/dev/null
mongosh --port 27019 --eval 'db.getSiblingDB("admin").shutdownServer()' &>/dev/null

echo "Replica set MongoDB local terminé."
