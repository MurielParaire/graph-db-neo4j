import org.apache.spark.sql.SparkSession

object Project {
  def main(args: Array[String]): Unit = {
    val url = "neo4j://<ip>:7687" // for local desktop
    val password = "<password>"
    val username = "neo4j"
    val dbname = "neo4j"

    val spark = SparkSession.builder
      .config("neo4j.url", url)
      .config("neo4j.authentication.basic.username", username)
      .config("neo4j.authentication.basic.password", password)
      .config("neo4j.database", dbname)
      .appName("Spark App")
      .master("local[*]")
      .getOrCreate()    

    val getTransactionTypes = """MATCH (cl:Client)-[]-(txn:Transaction)-[]-(c:Client:FirstPartyFraudster)
      WHERE NOT cl:FirstPartyFraudster
      UNWIND labels(txn) AS transactionType
      RETURN transactionType, count(*) AS freq"""

    val dfTransactionTypes = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", getTransactionTypes)
      .load()

    println("Types of transactions these clients perform with first party fraudsters:")
    dfTransactionTypes.show()



    val getCountFraudRingsGT9 = """MATCH (c:Client)
      WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
      WITH *, size(fGroup) AS groupSize WHERE groupSize > 9
      WITH collect(fpGroupID) AS fraudRings
      RETURN  size(fraudRings)"""

    val dfCountFraudRingsGT9 = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", getCountFraudRingsGT9)
      .load()

    println("Number of FraudRing clusters greater than 9:")
    dfCountFraudRingsGT9.show()



    val getCountFraudRingsGT10 = """MATCH (c:Client)
      WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
      WITH *, size(fGroup) AS groupSize WHERE groupSize > 10
      WITH collect(fpGroupID) AS fraudRings
      RETURN  size(fraudRings)"""

    val dfCountFraudRingsGT10 = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", getCountFraudRingsGT10)
      .load()

    println("Number of FraudRing clusters greater than 10:")
    dfCountFraudRingsGT10.show()
  }
}