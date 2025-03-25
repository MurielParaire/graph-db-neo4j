// find the details of all crimes under investigation by Officer Larive (badge number 26-5234182)
MATCH (:Officer{badge_no: "26-5234182"})<-[:INVESTIGATED_BY]-(c:Crime{last_outcome: "Under investigation"}) 
RETURN c

// output
// there are 8 crimes showing up

// if we want all crimes that Officer Larive has investigated we can look them up with
MATCH (:Officer{badge_no: "26-5234182"})<-[:INVESTIGATED_BY]-(c:Crime)
RETURN c
// but the results are too long to show

// if we want only to get the crimes under investigations about the type drugs: 
MATCH (o:Officer{badge_no: "26-5234182"})<-[i:INVESTIGATED_BY]-(c:Crime{last_outcome: "Under investigation", type: "Drugs"}) 
RETURN o, i, c
// there are 3 investigations
// we can see that two of these drug cases are linked -> the Person Jack is linked to both and the both of these happened on 23 Bodmin Road
// the third one is also linked, but only via 3 three intermediate persons (Jack, Alan, Philipp, Raymond)


// can we find the shortest path between two persons
MATCH p = SHORTEST 1 (p1:Person{name: "Jack", surname: "Powell"})-[:KNOWS|KNOWS_LW|KNOWS_PHONE|KNOWS_SN|FAMILY_REL]-+(p2:Person{name:"Raymond", surname:"Walker"})
RETURN [n in nodes(p) | n.name] AS stops

// output
/*
stops
["Jack", "Alan", "Kathleen", "Raymond"]
*/

// find the connection between the people involded in both crimes
MATCH (c:Crime {last_outcome: 'Under investigation', type: 'Drugs'})-[:INVESTIGATED_BY]->(:Officer {badge_no: '26-5234182'}),
(c)<-[:PARTY_TO]-(p:Person)
WITH COLLECT(p) AS persons
UNWIND persons AS p1
UNWIND persons AS p2
WITH * WHERE id(p1) < id(p2)
MATCH path = allshortestpaths((p1)-[:KNOWS|KNOWS_LW|KNOWS_SN|FAMILY_REL|KNOWS_PHONE*..3]-(p2)) // maximum 3 people away
RETURN path