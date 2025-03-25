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