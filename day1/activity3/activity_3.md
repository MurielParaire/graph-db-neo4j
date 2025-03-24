# Setup

We need to install Apoc. This can be achieved via the neo4j Desktop by clicking on the database > Plugins > Apoc > Install.
Then we need to restart out DBMS.

We will be using 2 files to test - the test_data.json file and the NVD CVE 2024 file. The latter one can be oobtained [here](https://nvd.nist.gov/vuln/data-feeds)

Both of these files need to be copied into the Import folder. Go to your project and click on ... > Open Folder > Import.


The last step to be able to import them, we need to allow Apoc to do so. Add a `apoc.conf` file with this line: `apoc.import.file.enabled=true` in ... > Open Folder > configuration.


# Tasks

***Task 1***
Import test_data.json file

```
CALL apoc.load.json("file:///test_data.json") YIELD value
```

Output:
```
{
  "name": "Person 1",
  "age": 25
}
{
  "name": "Person 2",
  "age": 30
}
{
  "name": "Person 3",
  "age": 35
}
{
  "name": "Person 4",
  "age": 40
}
```

***Task 2***

Get all keys from the nvdcve file:
```
WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND keys(value) AS key
RETURN key, apoc.meta.cypher.type(value[key]);
```

```
╒═══════════════════════╤═════════════════════════════════╕
│key                    │apoc.meta.cypher.type(value[key])│
╞═══════════════════════╪═════════════════════════════════╡
│"CVE_Items"            │"LIST OF MAP"                    │
├───────────────────────┼─────────────────────────────────┤
│"CVE_data_type"        │"STRING"                         │
├───────────────────────┼─────────────────────────────────┤
│"CVE_data_format"      │"STRING"                         │
├───────────────────────┼─────────────────────────────────┤
│"CVE_data_timestamp"   │"STRING"                         │
├───────────────────────┼─────────────────────────────────┤
│"CVE_data_numberOfCVEs"│"STRING"                         │
├───────────────────────┼─────────────────────────────────┤
│"CVE_data_version"     │"STRING"                         │
└───────────────────────┴─────────────────────────────────┘
```


***Task 3***
Get the number of vulnerabilities:
```
WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_data_numberOfCVEs as Cnt
RETURN Cnt
```

Or,
```
WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_Items as cve
RETURN count (cve)
```

Both commands generate the following output: 
```
Cnt
"37388"
```


***Task 4***
Return first 5 vulnerabilities:
```
WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_Items as data
RETURN data limit 5
```

Output is too long to show.

But, we can only look into their severity:
```
WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_Items as data
RETURN data.cve.CVE_data_meta.ID, data.impact.baseMetricV2.severity limit 5
```

Output:
```
╒═════════════════════════╤═════════════════════════════════╕
│data.cve.CVE_data_meta.ID│data.impact.baseMetricV2.severity│
╞═════════════════════════╪═════════════════════════════════╡
│"CVE-2024-0001"          │null                             │
├─────────────────────────┼─────────────────────────────────┤
│"CVE-2024-0002"          │null                             │
├─────────────────────────┼─────────────────────────────────┤
│"CVE-2024-0003"          │null                             │
├─────────────────────────┼─────────────────────────────────┤
│"CVE-2024-0004"          │null                             │
├─────────────────────────┼─────────────────────────────────┤
│"CVE-2024-0005"          │null                             │
└─────────────────────────┴─────────────────────────────────┘
```


***Task 5***

Now, we want to import the data from this json as nodes into our db.

```
CALL apoc.periodic.iterate("CALL apoc.load.json('file:///nvdcve-1.1-2024.json') YIELD value",
"UNWIND  value.CVE_Items AS data  \r\n"+
"UNWIND data.cve.references.reference_data AS references \r\n"+
"MERGE (cveItem:CVE {uid: apoc.create.uuid()}) \r\n"+
"ON CREATE SET cveItem.cveid = data.cve.CVE_data_meta.ID, cveItem.references = references.url",
 {batchSize:100, iterateList:true});
```

This however, doesn't seem to work with the CVE from 2024. Due ot time constraints, I couldn't retry it with the 2018 one and jumped straight to the next activity.