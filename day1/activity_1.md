***Task 1***

find all Persosn (only me)

```
MATCH (p:Person)
RETURN p
```

Output:
```json
{
  "identity": 1,
  "labels": [
    "Person"
  ],
  "properties": {
    "name": "Muriel",
    "age": 23
  },
  "elementId": "4:303ac7e5-fda3-484d-876c-80cd0f97ec68:1"
}
```

***Task 2***
Find all persons and cats that have a "HAS" relationship between them

```
MATCH (p:Person)-[r:HAS]->(c:Cat)
RETURN p, c, r
```

Output:
╒══════════════════════════════════╤══════════════════════════════════════════╤════════════════════╕
│p                                 │c                                         │r                   │
╞══════════════════════════════════╪══════════════════════════════════════════╪════════════════════╡
│(:Person {name: "Muriel",age: 23})│(:Cat {name: "Lucky",age: 11,since: 2015})│[:HAS {since: 2015}]│
├──────────────────────────────────┼──────────────────────────────────────────┼────────────────────┤
│(:Person {name: "Muriel",age: 23})│(:Cat {name: "Mona",age: 8})              │[:HAS {since: 2017}]│
└──────────────────────────────────┴──────────────────────────────────────────┴────────────────────┘

***Task 3***

Find all persons and cats that have a "HAS" relationship between them but only their names

```
MATCH (p:Person)-[r:HAS]->(c:Cat)
RETURN p.name, c.name, r.since
```

Output:

╒════════╤═══════╤═══════╕
│p.name  │c.name │r.since│
╞════════╪═══════╪═══════╡
│"Muriel"│"Lucky"│2015   │
├────────┼───────┼───────┤
│"Muriel"│"Mona" │2017   │
└────────┴───────┴───────┘

***Task 4***

Find all persons that have a "HAS" relationship with Cats named Mona but only their names

```
MATCH (p:Person)-[r:HAS]->(c:Cat)
WHERE c.name = "Mona"
RETURN p.name, c.name, r.since
```

Output:

╒════════╤══════╤═══════╕
│p.name  │c.name│r.since│
╞════════╪══════╪═══════╡
│"Muriel"│"Mona"│2017   │
└────────┴──────┴───────┘