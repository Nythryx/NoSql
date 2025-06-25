// Partie 1 : Préparation
use schoolDB;
db.createCollection("classes");

// Partie 2 : Insertion de Données
db.classes.insertOne({
  "className": "Mathematics 101",
  "professor": "John Doe",
  "students": [
    {
      "name": "Charlie",
      "age": 21,
      "grades": {
        "midterm": 79,
        "final": 92
      }
    },
    {
      "name": "Dylan",
      "age": 23,
      "grades": {
        "midterm": 79,
        "final": 87
      }
    },
    {
      "name": "Alice",
      "age": 20,
      "grades": {
        "midterm": 80,
        "final": 90
      }
    },
    {
      "name": "Bob",
      "age": 22,
      "grades": {
        "midterm": 75,
        "final": 85
      }
    }
  ]
});

// Partie 3 : Requêtes sur Documents Imbriqués

// Recherche des classes où au moins un étudiant a plus de 85 en note finale
db.classes.find({
  "students.grades.final": { $gt: 85 }
}).pretty();

// Mise à jour : Augmenter la note finale de Bob de 5 points
db.classes.updateOne(
  {
    "className": "Mathematics 101",
    "students.name": "Bob"
  },
  {
    $inc: { "students.$.grades.final": 5 }
  }
);

// Partie 4 : Ajout et Suppression d’Éléments Imbriqués

// Ajout de l’étudiant Charlie (encore, s'il n'est pas déjà dans la liste)
db.classes.updateOne(
  { "className": "Mathematics 101" },
  {
    $push: {
      "students": {
        "name": "Charlie",
        "age": 23,
        "grades": {
          "midterm": 82,
          "final": 88
        }
      }
    }
  }
);

// Suppression de l’étudiant Alice
db.classes.updateOne(
  { "className": "Mathematics 101" },
  {
    $pull: {
      "students": { "name": "Alice" }
    }
  }
);

// Partie 5 : Agrégations

// Calcul de la note moyenne finale des étudiants de Mathematics 101
db.classes.aggregate([
  { $match: { "className": "Mathematics 101" } },
  { $unwind: "$students" },
  {
    $group: {
      _id: "$className",
      moyenneFinale: { $avg: "$students.grades.final" }
    }
  }
]);

// Trouver la note finale maximale des étudiants de Mathematics 101
db.classes.aggregate([
  { $match: { "className": "Mathematics 101" } },
  { $unwind: "$students" },
  {
    $group: {
      _id: "$className",
      maxFinal: { $max: "$students.grades.final" }
    }
  }
]);

// Validation : Affichage du document mis à jour
db.classes.find().pretty();
