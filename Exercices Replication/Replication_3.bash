#!/bin/bash

# Définition des ports pour chaque instance mongod
PORT1=27017
PORT2=27018
PORT3=27019

# Création des répertoires pour les fichiers de données
mkdir -p db1 db2 db3

# Démarrage des instances mongod en arrière-plan
mongod --replSet "rs0" --port $PORT1 --dbpath ./db1 --bind_ip localhost --fork --logpath ./db1/mongod.log
mongod --replSet "rs0" --port $PORT2 --dbpath ./db2 --bind_ip localhost --fork --logpath ./db2/mongod.log
mongod --replSet "rs0" --port $PORT3 --dbpath ./db3 --bind_ip localhost --fork --logpath ./db3/mongod.log

# Pause pour s'assurer que les instances sont bien démarrées
sleep 5

# Initialisation du replica set depuis le premier mongod
mongo --port $PORT1 <<EOF
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:$PORT1" },
    { _id: 1, host: "localhost:$PORT2" },
    { _id: 2, host: "localhost:$PORT3" }
  ]
})
EOF

# Pause pour permettre à la configuration de se propager
sleep 5

# Vérification du statut du replica set
mongo --port $PORT1 --eval "rs.status()"
