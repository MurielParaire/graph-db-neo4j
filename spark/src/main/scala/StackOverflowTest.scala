
import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.types.{IntegerType, StringType, StructType}

object StackOverflowTest {
    def main(args: Array[String]): Unit = {

        val programStartTime = System.nanoTime()

        Logger.getLogger("org").setLevel(Level.ERROR)

        val csvDataFile = "data/stackoverflow.csv"

        val spark = SparkSession.builder
          .appName("Stackoverflow Application")
          .config("spark.driver.memory", "8G")
          .master("local[*]")
          .getOrCreate()

        spark.sparkContext.setLogLevel("ERROR")

        val schema = new StructType()
          .add("postTypeId", IntegerType, nullable = true)
          .add("id", IntegerType, nullable = true)
          .add("acceptedAnswer", StringType, nullable = true)
          .add("parentId", IntegerType, nullable = true)
          .add("score", IntegerType, nullable = true)
          .add("tag", StringType, nullable = true)

        val df = spark.read
          .option("header", "false")
          // .option("inferSchema", "true")
          .schema(schema)
          .csv(csvDataFile)
          .drop("acceptedAnswer")

        println(s"\nCount of records in CSV file: ${df.count()}")
        df.printSchema()
        df.show(5)

        import spark.implicits._

        println(
            //"Count acceptedAnswer null: "+ df.filter(col("acceptedAnswer").isNull).count()
            "\nCount tag null: "+ df.filter($"tag".isNull).count()
              + "\nCount parentId null: "+ df.filter($"parentId".isNull).count() )

        // Filter posts with a score greater than 10
        val highScorePosts = df
          .filter(col("score") > 20)

        highScorePosts.show(5)

        // Register the DataFrame as a SQL temporary view
        df.createOrReplaceTempView("stackoverflow")

        // Query 1: Top 5 highest scores
        val top5Scores = spark.sql("SELECT id, score FROM stackoverflow ORDER BY score DESC LIMIT 5")
        top5Scores.show()

        val top5ScoresWithTag = spark.sql("""
        SELECT id, score, tag
        FROM stackoverflow
        WHERE tag IS NOT NULL
        ORDER BY score DESC
        LIMIT 5
      """)
        top5ScoresWithTag.show()

        // Query: Most frequently used tags
        val popularTags = spark.sql("""
      SELECT tag, COUNT(*) as frequency
      FROM stackoverflow
      WHERE tag IS NOT NULL
      GROUP BY tag
      ORDER BY frequency DESC
      LIMIT 10
    """)
        popularTags.show()




        //    highScorePosts.sort("score").show(5)

        val programElapsedTime = (System.nanoTime() - programStartTime) / 1e9
        println(s"\nProgram execution time: $programElapsedTime seconds")
        spark.stop()
    }
}


