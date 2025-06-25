// 1. Sélection de la base de données (créée si n'existe pas)
use PokemonDB

// 2. Création de la collection (optionnel car auto-créée à l'insertion)
db.createCollection("Pokemons")

// 3. Insertion des données (exemple avec 3 Pokémon)
// Remplace ces données par l'import réel ou adapte selon ton fichier CSV
db.Pokemons.insertMany([
  { name: "Pikachu", type: ["Electrik"], cp: 500 },
  { name: "Charmander", type: ["Feu"], cp: 600 },
  { name: "Bulbasaur", type: ["Plante", "Poison"], cp: 450 }
])

// 4. Lecture - Trouver tous les Pokémon de type "Feu"
const feu = db.Pokemons.find({ type: "Feu" }).toArray()
print("Pokémons de type Feu :")
printjson(feu)

// 5. Lecture - Récupérer Pikachu
const pikachu = db.Pokemons.findOne({ name: "Pikachu" })
print("Données de Pikachu :")
printjson(pikachu)

// 6. Mise à jour - Modifier le CP de Pikachu à 900
db.Pokemons.updateOne({ name: "Pikachu" }, { $set: { cp: 900 } })

// Vérifier la mise à jour
const pikachuUpdated = db.Pokemons.findOne({ name: "Pikachu" })
print("Pikachu après mise à jour :")
printjson(pikachuUpdated)

// 7. Suppression - Supprimer Bulbasaur
db.Pokemons.deleteOne({ name: "Bulbasaur" })

// Vérifier la suppression
const bulbasaur = db.Pokemons.findOne({ name: "Bulbasaur" })
print("Bulbasaur après suppression (doit être null) :")
printjson(bulbasaur)
