// look at the number of Airports and HAS_NODE relationships
CALL gds.graph.project(
    'routes',
    'Airport',
    'HAS_ROUTE'
)
YIELD
    graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount

// this command returns a projection of the number of nodes and relationShips of type HAS_NODE

// verify that the numbers are correct
// this can either be done getting the count of all nodes or relationships in two separate commands
// get node count
MATCH (a:Airport)
RETURN COUNT(a)
// get HAS_ROUTE relationships count
MATCH (:Airport)-[r:HAS_ROUTE]->(:Airport)
RETURN COUNT(r)
// should return same numbers as above => our previous code works
// we can also do both in the same ocmmand by using apoc.meta.stats:
CALL apoc.meta.stats() YIELD labels, relTypesCount
RETURN labels, relTypesCount
//this will return the count for all nodes and edges

// use a centrality algorithm
CALL gds.pageRank.stream('routes')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score AS pageRank
RETURN n.iata AS iata, n.descr AS description, pageRank
ORDER BY pageRank DESC, iata ASC
// this returns a pageRank for each airport -> we can see that the first one is DFW (Dallas), then Chicago (ORD) followed by Denver (DEN) airport

// to store this result in each airport, we can use 
CALL gds.pageRank.write('routes',
    {
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations
// it automatically knows to add the pagerank to the airports because of teh "routes" keyword we used before to stream
// now each airport has a new property - pageRank


// now let's look a the different clusters / communitites
// Uncovering distinct clusters or communities of nodes, shedding light on cohesive groups or substructures within a graph. 
CALL gds.louvain.stream('routes')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS n, communityId
RETURN
    communityId,
    SIZE(COLLECT(n)) AS numberOfAirports,
    COLLECT(DISTINCT n.city) AS cities
ORDER BY numberOfAirports DESC, communityId;

// and the simlilarity between different cities can be shown with
// Node similarity
CALL gds.nodeSimilarity.stream('routes')
YIELD node1, node2, similarity
WITH gds.util.asNode(node1) AS n1, gds.util.asNode(node2) AS n2, similarity
RETURN
    n1.iata AS iata,
    n1.city AS city,
    COLLECT({iata:n2.iata, city:n2.city, similarityScore: similarity}) AS similarAirports
ORDER BY city LIMIT 20

// the output shows us that the two cities Aberdeen (ABR) and Hibbing (HIB) are very similar as they share a similarity code of 1
// other cities like Aalborg (AAL) and Kjevik (KRS) are less similar, with only 0.33
// we can decide to only show similar cities:
// Node similarity: topN and bottomN
CALL gds.nodeSimilarity.stream(
    'routes',
    {
        topK: 1,
        topN: 10
    }
)
YIELD node1, node2, similarity
WITH gds.util.asNode(node1) AS n1, gds.util.asNode(node2) AS n2, similarity AS similarityScore
RETURN
    n1.iata AS iata,
    n1.city AS city,
    {iata:n2.iata, city:n2.city} AS similarAirport,
    similarityScore
ORDER BY city
// output
/*
╒═════╤══════════════════════╤════════════════════════════════════════╤═══════════════╕
│iata │city                  │similarAirport                          │similarityScore│
╞═════╪══════════════════════╪════════════════════════════════════════╪═══════════════╡
│"ABI"│"Abilene"             │{iata: "TXK", city: "Texarkana"}        │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"AEX"│"Alexandria"          │{iata: "GRK", city: "Fort Hood/Killeen"}│1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"BPT"│"Beaumont/Port Arthur"│{iata: "TXK", city: "Texarkana"}        │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"CLL"│"College Station"     │{iata: "LCH", city: "Lake Charles"}     │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"DRO"│"Durango"             │{iata: "SAF", city: "Santa Fe"}         │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"GCK"│"Garden City"         │{iata: "TXK", city: "Texarkana"}        │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"IAG"│"Niagara Falls"       │{iata: "PSM", city: "Portsmouth"}       │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"SAF"│"Santa Fe"            │{iata: "DRO", city: "Durango"}          │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"TXK"│"Texarkana"           │{iata: "ABI", city: "Abilene"}          │1.0            │
├─────┼──────────────────────┼────────────────────────────────────────┼───────────────┤
│"ACT"│"Waco"                │{iata: "TXK", city: "Texarkana"}        │1.0            │
└─────┴──────────────────────┴────────────────────────────────────────┴───────────────┘
*/

// now, let's try to find the shortes route between Denver and Malbourne

MATCH (src:Airport{iata:"DEN"})-[:HAS_ROUTE]->(dest:Airport{iata:"MEL"})
RETURN src, dest

// if we put it like this, no route can be found. Why ? 
// maybe because there aren't any direct flights. Let's try to look for solutions where you have to take at least 2 flights
//Creating a weighted graph projection

CALL gds.graph.project(
    'routes-weighted',
    'Airport',
    'HAS_ROUTE',
    {
        relationshipProperties: 'distance'
    }
) YIELD
    graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount

// searching shortes route
MATCH (src:Airport {iata: 'DEN'}), (dest:Airport {iata: 'MEL'})
CALL gds.shortestPath.dijkstra.stream('routes-weighted', {
    sourceNode: src,
    targetNode: dest,
    relationshipWeightProperty: 'distance'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    gds.util.asNode(sourceNode).iata AS source,
    gds.util.asNode(targetNode).iata AS target,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).iata] AS stops,
    costs,
    nodes(path) as path
ORDER BY index

// this shows us that the shortest way between Denver and Melbourne is by passing through Los Angeles
/*
╒══════╤══════╤═════════╤═════════════════════╤════════════════════╤══════════════════════════════════════════════════════════════════════╕
│source│target│totalCost│stops                │costs               │path                                                                  │
╞══════╪══════╪═════════╪═════════════════════╪════════════════════╪══════════════════════════════════════════════════════════════════════╡
│"DEN" │"MEL" │8782.0   │["DEN", "LAX", "MEL"]│[0.0, 860.0, 8782.0]│[(:Airport {altitude: 5433,descr: "Denver International Airport",pageR│
│      │      │         │                     │                    │ank: 10.997299338126384,longest: 16000,iata: "DEN",city: "Denver",icao│
│      │      │         │                     │                    │: "KDEN",location: point({srid:4326, x:-104.672996520996, y:39.8616981│
│      │      │         │                     │                    │506348}),id: "31",pagerank: 10.997299338126387,runways: 6}), (:Airport│
│      │      │         │                     │                    │ {altitude: 127,descr: "Los Angeles International Airport",pageRank: 8│
│      │      │         │                     │                    │.193558075446688,longest: 12091,iata: "LAX",city: "Los Angeles",icao: │
│      │      │         │                     │                    │"KLAX",location: point({srid:4326, x:-118.4079971, y:33.94250107}),id:│
│      │      │         │                     │                    │ "13",pagerank: 8.193558075446687,runways: 4}), (:Airport {altitude: 4│
│      │      │         │                     │                    │34,descr: "Melbourne International Airport",pageRank: 3.52525715730183│
│      │      │         │                     │                    │9,longest: 11998,iata: "MEL",city: "Melbourne",icao: "YMML",location: │
│      │      │         │                     │                    │point({srid:4326, x:144.843002319336, y:-37.6733016967773}),id: "57",p│
│      │      │         │                     │                    │agerank: 3.525257157301838,runways: 2})]                              │
└──────┴──────┴─────────┴─────────────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────┘
*/

