# --------------------------------------
# Exercice 1 : Importation des données
# --------------------------------------

# Créez la base de données TitanicDB et importez le fichier CSV
# À exécuter dans un terminal (pas dans le shell MongoDB)
mongoimport --db TitanicDB --collection Passengers --type csv --headerline --file titanic.csv

# --------------------------------------
# Connectez-vous à la base
# --------------------------------------
mongosh

use TitanicDB

# --------------------------------------
# Exercice 2 : Analyse des données
# --------------------------------------

# 1. Nombre total de passagers
db.Passengers.countDocuments()

# 2. Nombre de passagers ayant survécu (Survived = 1)
db.Passengers.countDocuments({ Survived: "1" })

# 3. Nombre de femmes
db.Passengers.countDocuments({ Sex: "female" })

# 4. Nombre de passagers avec au moins 3 enfants (SibSp >= 3)
db.Passengers.countDocuments({ SibSp: { $gte: 3 } })

# --------------------------------------
# Exercice 3 : Mise à jour de données
# --------------------------------------

# 1. Mettre 'Embarked' à 'S' si manquant ou vide
db.Passengers.updateMany(
  { $or: [{ Embarked: "" }, { Embarked: { $exists: false } }] },
  { $set: { Embarked: "S" } }
)

# 2. Ajouter un champ 'rescued: true' aux survivants
db.Passengers.updateMany(
  { Survived: "1" },
  { $set: { rescued: true } }
)

# --------------------------------------
# Exercice 4 : Requêtes complexes
# --------------------------------------

# 1. Les noms des 10 passagers les plus jeunes
db.Passengers.find(
  { Age: { $ne: "" } },
  { Name: 1, Age: 1, _id: 0 }
).sort({ Age: 1 }).limit(10)

# 2. Passagers NON survivants (Survived = 0) en 2e classe (Pclass = 2)
db.Passengers.find(
  { Survived: "0", Pclass: "2" },
  { Name: 1, Pclass: 1, Survived: 1, _id: 0 }
)

# --------------------------------------
# Exercice 5 : Suppression de données
# --------------------------------------

# Supprimer les passagers non survivants et dont l'âge est inconnu
db.Passengers.deleteMany(
  { Survived: "0", $or: [{ Age: "" }, { Age: { $exists: false } }] }
)

# --------------------------------------
# Exercice 6 : Mise à jour en masse
# --------------------------------------

# Incrémenter l’âge de tous les passagers de 1 an
db.Passengers.updateMany(
  { Age: { $ne: "" } },
  [
    { $set: { Age: { $add: [{ $toDouble: "$Age" }, 1] } } }
  ]
)

# --------------------------------------
# Exercice 7 : Suppression conditionnelle
# --------------------------------------

# Supprimer les documents sans ticket ou avec un ticket vide
db.Passengers.deleteMany(
  { $or: [{ Ticket: "" }, { Ticket: { $exists: false } }] }
)

# --------------------------------------
# Bonus : Utilisation des expressions régulières
# --------------------------------------

# Trouver tous les passagers ayant "Dr." dans le champ Name
db.Passengers.find(
  { Name: { $regex: /Dr\./i } },
  { Name: 1, _id: 0 }
)

# --------------------------------------
# Fin du script
# --------------------------------------
