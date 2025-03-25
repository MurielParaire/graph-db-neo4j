// populate database
MATCH (n) DETACH DELETE n;

CREATE
    (mateo:User {name: "Matéo" }),
    (adrien:User {name: "Adrien" }),
    (noe:User {name: "Noé" }),
    (muriel:User {name: "Muriel" }),
    (thomas:User {name: "Thomas" }),
    (vincent:User {name: "Vincent" }),
    (martin:User {name: "Martin" }),
    (dziyana:User {name: "Dziyana" }),
    (charley:User {name: "Charley" }),
    (remi:User {name: "Rémi" }),
    (fabien:User {name: "Fabien" }),
    (alexandre:User {name: "Alexandre" }),
    (sylvain:User {name: "Sylvain" }),
    (mathias:User {name: "Mathias" }),
    (m0:Movie {title: "The Matrix", genre: "Action"}),
    (m1:Movie {title: "Inception", genre: "Sci-Fi" }),
    (m2:Movie {title: "The Godfather", genre: "Drama" }),
    (m3:Movie {title: "Forest Gump", genre: "Drama"}),
    (m4:Movie {title: "Interstellar", genre: "Sci-Fi" }),
    (m5:Movie {title: "Mission Impossible", genre: "Action" }),
    (m6:Movie {title: "La La Land", genre: "Musical" }),
    (m7:Movie {title: "The Dark Knight", genre: "Action"}),
    (m8:Movie {title: "Pulp Fiction", genre: "Crime"}),
    (m9:Movie {title: "The Shawshank Redemption", genre: "Drama"}),
    (m10:Movie {title: "Star Wars: A New Hope", genre: "Sci-Fi"}),
    (m11:Movie {title: "The Lion King", genre: "Animation"}),
    (m12:Movie {title: "The Silence of the Lambs", genre: "Thriller"}),
    (m13:Movie {title: "Amélie Poulain", genre: "Romance"}),
    (m14:Movie {title: "The Grand Budapest Hotel", genre: "Comedy"}),
    (mateo)-[:LIKES]->(m0),
    (alexandre)-[:LIKES]->(m2),
    (remi)-[:LIKES]->(m4),
    (thomas)-[:LIKES]->(m4),
    (noe)-[:LIKES]->(m5),
    (muriel)-[:LIKES]->(m1),
    (mathias)-[:LIKES]->(m1),
    (sylvain)-[:LIKES]->(m0),
    (fabien)-[:LIKES]->(m5),
    (vincent)-[:LIKES]->(m4),
    (martin)-[:LIKES]->(m0),
    (adrien)-[:LIKES]->(m4),
    (charley)-[:LIKES]->(m4),
    (dziyana)-[:LIKES]->(m0),
    (mateo)-[:LIKES]->(m7),
    (mateo)-[:LIKES]->(m10),
    (adrien)-[:LIKES]->(m9),
    (adrien)-[:LIKES]->(m13),
    (noe)-[:LIKES]->(m8),
    (noe)-[:LIKES]->(m12),
    (muriel)-[:LIKES]->(m11),
    (muriel)-[:LIKES]->(m14),
    (thomas)-[:LIKES]->(m10),
    (thomas)-[:LIKES]->(m7),
    (vincent)-[:LIKES]->(m9),
    (vincent)-[:LIKES]->(m2),
    (martin)-[:LIKES]->(m8),
    (martin)-[:LIKES]->(m12),
    (dziyana)-[:LIKES]->(m13),
    (dziyana)-[:LIKES]->(m11),
    (charley)-[:LIKES]->(m14),
    (charley)-[:LIKES]->(m3),
    (remi)-[:LIKES]->(m7),
    (remi)-[:LIKES]->(m9),
    (fabien)-[:LIKES]->(m8),
    (fabien)-[:LIKES]->(m12),
    (alexandre)-[:LIKES]->(m10),
    (alexandre)-[:LIKES]->(m11),
    (sylvain)-[:LIKES]->(m13),
    (sylvain)-[:LIKES]->(m14),
    (mathias)-[:LIKES]->(m3),
    (mathias)-[:LIKES]->(m6),
    (mateo)-[:FRIENDS_WITH]->(adrien),
    (mateo)-[:FRIENDS_WITH]->(noe),
    (mateo)-[:FRIENDS_WITH]->(sylvain),
    (adrien)-[:FRIENDS_WITH]->(vincent),
    (adrien)-[:FRIENDS_WITH]->(charley),
    (noe)-[:FRIENDS_WITH]->(fabien),
    (noe)-[:FRIENDS_WITH]->(thomas),
    (muriel)-[:FRIENDS_WITH]->(mathias),
    (muriel)-[:FRIENDS_WITH]->(dziyana),
    (thomas)-[:FRIENDS_WITH]->(remi),
    (vincent)-[:FRIENDS_WITH]->(martin),
    (martin)-[:FRIENDS_WITH]->(alexandre),
    (charley)-[:FRIENDS_WITH]->(remi),
    (fabien)-[:FRIENDS_WITH]->(sylvain),
    (alexandre)-[:FRIENDS_WITH]->(mathias);


/*
Query #1: Recommend movies liked by similar users.
For example:

Recommend movie to "Muriel" based on similar users liked.
Recommend movie to "Dziyana" based on similar users liked.
*/
// Recomment movie to "Muriel" based on movies her friends have watched
MATCH (muriel:User {name: 'Muriel'})-[:FRIENDS_WITH]->(friend:User)-[:LIKES]->(movie:Movie)
WHERE NOT (muriel)-[:LIKES]->(movie)
RETURN movie.title, movie.genre, friend.name

// output
/*
Table
Text
Code
╒════════════════╤═══════════╤═══════════╕
│movie.title     │movie.genre│friend.name│
╞════════════════╪═══════════╪═══════════╡
│"The Matrix"    │"Action"   │"Dziyana"  │
├────────────────┼───────────┼───────────┤
│"Amélie Poulain"│"Romance"  │"Dziyana"  │
├────────────────┼───────────┼───────────┤
│"Forest Gump"   │"Drama"    │"Mathias"  │
├────────────────┼───────────┼───────────┤
│"La La Land"    │"Musical"  │"Mathias"  │
└────────────────┴───────────┴───────────┘
*/

// Now we want to recommend movies to "Dziyana", we can try using the same code:
MATCH (dziyana:User {name: 'Dziyana'})-[:FRIENDS_WITH]->(friend:User)-[:LIKES]->(movie:Movie)
WHERE NOT (dziyana)-[:LIKES]->(movie)
RETURN movie.title, movie.genre, friend.name

// however, Dziyana is not friends with anybody, so she'll get no notifications
// we'll have to treat any FRIENDS_WITH as bidirectional to also get her the recommendations based on users that are friends with her
MATCH (dziyana:User {name: 'Dziyana'})-[:FRIENDS_WITH]-(friend:User)-[:LIKES]->(movie:Movie)
WHERE NOT (dziyana)-[:LIKES]->(movie)
RETURN movie.title, movie.genre, friend.name

// output
/*
╒══════════════════════════╤═══════════╤═══════════╕
│movie.title               │movie.genre│friend.name│
╞══════════════════════════╪═══════════╪═══════════╡
│"Inception"               │"Sci-Fi"   │"Muriel"   │
├──────────────────────────┼───────────┼───────────┤
│"The Grand Budapest Hotel"│"Comedy"   │"Muriel"   │
└──────────────────────────┴───────────┴───────────┘
*/

// we can even try to get the friends of friends of Dziyana
MATCH(dziyana:User {name: "Dziyana"})-[:FRIENDS_WITH*..2]-(friend:User)-[:LIKES]->(movie:Movie)
WHERE NOT (dziyana)-[:LIKES]->(movie)
RETURN COLLECT(DISTINCT friend.name) as friends, movie.title, movie.genre;

// output
/*
╒═════════════════════╤══════════════════════════╤═══════════╕
│friends              │movie.title               │movie.genre│
╞═════════════════════╪══════════════════════════╪═══════════╡
│["Muriel", "Mathias"]│"Inception"               │"Sci-Fi"   │
├─────────────────────┼──────────────────────────┼───────────┤
│["Muriel"]           │"The Grand Budapest Hotel"│"Comedy"   │
├─────────────────────┼──────────────────────────┼───────────┤
│["Mathias"]          │"Forest Gump"             │"Drama"    │
├─────────────────────┼──────────────────────────┼───────────┤
│["Mathias"]          │"La La Land"              │"Musical"  │
└─────────────────────┴──────────────────────────┴───────────┘
*/

// Query #2: If we know that Vincent likes science fiction how can we recommend movies in the same genre
MATCH (movie:Movie {genre: "Sci-Fi"}), (vincent:User{name: "Vincent"})
WHERE NOT (vincent)-[:LIKES]->(movie)
RETURN movie.title

// output
/*
╒═══════════════════════╕
│movie.title            │
╞═══════════════════════╡
│"Inception"            │
├───────────────────────┤
│"Star Wars: A New Hope"│
└───────────────────────┘
*/