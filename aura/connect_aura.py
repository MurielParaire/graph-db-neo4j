import os
from neo4j import GraphDatabase
from dotenv import load_dotenv

load_dotenv()
URI = os.getenv("AURA_URI")
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