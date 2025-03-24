import os
from neo4j import GraphDatabase
from dotenv import load_dotenv

load_dotenv()
# URI examples: "neo4j://localhost", "neo4j+s://xxx.databases.neo4j.io"
URI = "neo4j+s://81260a3b.databases.neo4j.io"
USERNAME = os.getenv("AURA_USERNAME")
PASSWORD = os.getenv("AURA_PASSWORD")
AUTH = (USERNAME, PASSWORD)

with GraphDatabase.driver(URI, auth=AUTH) as driver:
    driver.verify_connectivity()

    records, summary, keys = driver.execute_query( # (1)
        "RETURN COUNT {()} AS count"
    )

    # Get the first record
    first = records[0]      # (2)

    # Print the count entry
    print(first["count"])   # (3)

    driver.close()