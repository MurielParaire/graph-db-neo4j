package fr.umontpellier.polytech

import org.apache.spark.sql.{SparkSession, Dataset}
import org.apache.spark.sql.functions._
import org.apache.spark.SparkFiles
import org.apache.spark._
import org.apache.spark.streaming._

object SparkMinIOStreaming {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
        .builder
        .appName("SparkMinIOStreaming")
        .master("local[*]")
        .getOrCreate()
    import spark.implicits._
    val lines = spark.readStream
        .option("startingPosition","earliest")
        .option("host", "localhost")
        .option("port", "9000")
        .text("s3a://streaming/input/")

    val words = lines.as[String].flatMap(_.split(" "))
    
    val query = words.writeStream
        .outputMode("append")
        .format("console") 
        .start()

    val s3Output = lines.writeStream
      .format("text")
      .outputMode("append")
      .option("checkpointLocation", "s3a://streaming/checkpoints/")
      .start("s3a://streaming/output/")
    
    query.awaitTermination()

  }
}
