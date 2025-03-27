package fr.umontpellier.polytech

import org.apache.spark.sql.SparkSession

object WikipediaNLP extends App {

  val spark = SparkSession.builder
    .appName("WikipediaNLP")
    .master("local[*]")
    .getOrCreate()

  import spark.implicits._

  val rawData = spark.sparkContext.textFile("data/wikipedia.dat")

  case class WikiPage(title: String, text: String, isRedirect: Boolean)

  def parseWikiPage(pageString: String): WikiPage = {
    val titleRegex = "<title>(.*?)</title>".r
    val textRegex = "<text>(.*?)</text>".r

    val title = titleRegex.findFirstMatchIn(pageString).map(_.group(1)).getOrElse("")
    val text = textRegex.findFirstMatchIn(pageString).map(_.group(1)).getOrElse("")
    val isRedirect = text.contains("#REDIRECT")

    WikiPage(title, text, isRedirect)
  }

  val wikiPageRDD = rawData.map(parseWikiPage)
  val wikiPageDF = wikiPageRDD.toDF()
  wikiPageDF.show(5, false)

  wikiPageDF.groupBy("isRedirect")
    .count()
    .show()

  import org.apache.spark.sql.functions._

  val categoryPattern = "\\[\\[Category:(.*?)]]".r

  val extractCategories = udf { text: String =>
    categoryPattern.findAllMatchIn(text).map(_.group(1)).toSeq
  }

  val wikiWithCategories = wikiPageDF
    .withColumn("categories", extractCategories(col("text")))

  wikiWithCategories.select("title", "categories").show(false)

  val exploded = wikiWithCategories
    .withColumn("category", explode(col("categories")))

  exploded.groupBy("category")
    .count()
    .orderBy(desc("count"))
    .show(50, truncate = false)

  spark.stop()

}