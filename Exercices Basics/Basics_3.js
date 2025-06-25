// Partie 1 : Exploration des Bases de Données et Collections

// Connexion : Démarrage automatique en lançant `mongosh`
// Lister les Bases de Données
show dbs

// Sélectionner une base de données (elle sera créée si elle n'existe pas)
use testDB

// Créer une collection nommée testCollection
db.createCollection("testCollection")

// Afficher les collections de la base actuelle
show collections

// Partie 2 : Manipulation des Données

// Insertion d’un document dans testCollection
db.testCollection.insertOne({name: "test", value: 1})

// Lecture des documents dans testCollection
db.testCollection.find()

// Mise à jour du document : on incrémente "value" de 1
db.testCollection.updateOne({name: "test"}, {$inc: {value: 1}})

// Vérification après mise à jour
db.testCollection.find()

// Suppression du document
db.testCollection.deleteOne({name: "test"})

// Vérification après suppression
db.testCollection.find()

// Partie 3 : Nettoyage

// Suppression de la collection
db.testCollection.drop()

// Vérification après suppression de la collection
show collections

// Suppression de la base de données (assurez-vous d'être dans testDB)
db.dropDatabase()

// Vérification après suppression de la base
show dbs
