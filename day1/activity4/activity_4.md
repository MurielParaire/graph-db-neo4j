# Setup

Clear database:
```
MATCH (n) DETACH DELETE n
```

Load the file [movies.csv](./movies.csv) into the Import folder of the database.

# Tasks


***Task 1***

Count number of movies:
```
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS csvLine
RETURN count(csvLine)
```

Output:
```
count(csvLine)
3
```

***Task 2***

Create the movies from this file:
```
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS csvLine
MERGE (country:Country { name: csvLine.country })
CREATE (movie:Movie { id: toInteger(csvLine.id), title: csvLine.title, year:toInteger(csvLine.year)})
CREATE (movie)-[:MADE_IN]->(country)
```

We can verify that it has been imported by running:
```
MATCH (n:Movie)-[r:MADE_IN]->(c:Country)
RETURN n,r,c
```

Output:
```
╒═════════════════════════════════════════════════════════════╤══════════╤════════════════════════╕
│n                                                            │r         │c                       │
╞═════════════════════════════════════════════════════════════╪══════════╪════════════════════════╡
│(:Movie {year: 1987,id: 1,title: "Wall Street"})             │[:MADE_IN]│(:Country {name: "USA"})│
├─────────────────────────────────────────────────────────────┼──────────┼────────────────────────┤
│(:Movie {year: 1995,id: 2,title: "The American President"})  │[:MADE_IN]│(:Country {name: "USA"})│
├─────────────────────────────────────────────────────────────┼──────────┼────────────────────────┤
│(:Movie {year: 1994,id: 3,title: "The Shawshank Redemption"})│[:MADE_IN]│(:Country {name: "USA"})│
└─────────────────────────────────────────────────────────────┴──────────┴────────────────────────┘
```