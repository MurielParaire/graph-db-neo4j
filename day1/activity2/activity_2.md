# Setup

We will work on the Movie database.

For the next part, you need to change the memory settings (this supposes you have at least 8G of memory):

On your project in Neo4j Desktop open settings and scroll to the bottom.
Change the following lines to match this:

```
dbms.memory.heap.initial_size=1024m
dbms.memory.heap.max_size=4G
dbms.memory.pagecache.size=2G
```

Then we have to clear our database:
```
MATCH (n) DETACH DELETE n
```

This command will delete everything in it.

To view the schema:
```
CALL db.schema.visualization
```

# Tasks

***Task 1***

Return all movies that have been released betweeen 2005 and 2010:

```
MATCH (m:Movie)
WHERE m.released > 2005 AND m.released < 2010
RETURN m
```

Output:
```
╒══════════════════════════════════════════════════════════════════════╕
│m                                                                     │
╞══════════════════════════════════════════════════════════════════════╡
│(:Movie {tagline: "Based on the extraordinary true story of one man's │
│fight for freedom",title: "RescueDawn",released: 2006})               │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "Break The Codes",title: "The Da Vinci Code",release│
│d: 2006})                                                             │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "Freedom! Forever!",title: "V for Vendetta",released│
│: 2006})                                                              │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "Speed has no limits",title: "Speed Racer",released:│
│ 2008})                                                               │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "Prepare to enter a secret world of assassins",title│
│: "Ninja Assassin",released: 2009})                                   │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "400 million people were waiting for the truth.",tit│
│le: "Frost/Nixon",released: 2008})                                    │
├──────────────────────────────────────────────────────────────────────┤
│(:Movie {tagline: "A stiff drink. A little mascara. A lot of nerve. Wh│
│o said they couldn't bring down the Soviet empire.",title: "Charlie Wi│
│lson's War",released: 2007})                                          │
└──────────────────────────────────────────────────────────────────────┘
```

To get the number of movies:
```
MATCH (m:Movie)
WHERE m.released > 2005 AND m.released < 2010
RETURN COUNT(m)
```

Output:
```
╒════════╕
│COUNT(m)│
╞════════╡
│7       │
└────────┘
```

***Task 2***

```
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WITH m, collect(p) AS Actors
WHERE size(Actors) > 2
RETURN m.title, size(Actors) AS NB_Actors
```
First lines of output:
```
╒════════════════════════╤═════════╕
│m.title                 │NB_Actors│
╞════════════════════════╪═════════╡
│"The Matrix"            │5        │
├────────────────────────┼─────────┤
│"The Matrix Reloaded"   │4        │
├────────────────────────┼─────────┤
│"The Matrix Revolutions"│4        │
├────────────────────────┼─────────┤
```


***Task 3***

Return first and last movie.

```
MATCH (m:Movie)
RETURN MIN(m.released), MAX(m.released)
```

Output:

```
╒═══════════════╤═══════════════╕
│MIN(m.released)│MAX(m.released)│
╞═══════════════╪═══════════════╡
│1975           │2012           │
└───────────────┴───────────────┘
```


***Task 4***

Create a new Actor (us) and a Movie in which we have acted in.

1. Create actor

```
CREATE (p:Person {born:2001, name: "Muriel"} )
```
You should see `Added 1 label, created 1 node set 2 properties`. This indicates that the Person has been created successfully.

2. Create Movie

```
CREATE (m:Movie {released: 2025, title: "The Story of Teyvat", tagline: "Best movie ever", genre: "Fantasy"})
```
Or, if you want to add genre afterwards: 
```
CREATE (m:Movie {released: 2025, title: "The Story of Teyvat", tagline: "Best movie ever", genre: "Fantasy"})
``` 
```
MATCH (m:Movie {title: "The Story of Teyvat"})
SET m.genre = "Fantasy"
```

As for Step 1, you should have confirmation after each command that something has been created.

3. Create relationship

```
MATCH (p:Person {name: "Muriel"}), (m:Movie {title: "The Story of Teyvat"})
CREATE (p)-[:ACTED_IN]->(m)
```
Output should show that it was created.

4. Verify

To verify, that everything was created as we wished, we can run:
```
MATCH (p:Person {name: "Muriel"})-[r:ACTED_IN]->(m:Movie {title: "The Story of Teyvat"})
RETURN p,r,m
```

Output:
```
═════════════════════════════════╤═══════════╤══════════════════════════════════════════════════════════════════════╕
│p                                    │r          │m                                                                     │
╞═════════════════════════════════════╪═══════════╪══════════════════════════════════════════════════════════════════════╡
│(:Person {born: 2001,name: "Muriel"})│[:ACTED_IN]│(:Movie {genre: "Fantasy",tagline: "Best movie ever",title: "The Story│
│                                     │           │ of Teyvat",released: 2025})                                          │
└─────────────────────────────────────┴───────────┴──────────────────────────────────────────────────────────────────────┘
```

