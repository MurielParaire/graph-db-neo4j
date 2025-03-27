package fr.umontpellier.polytech

import org.apache.spark.sql.{SparkSession, Dataset}
import org.apache.spark.sql.functions._
import org.apache.spark.SparkFiles
import org.apache.spark._
import org.apache.spark.streaming._



object SparkKafkaStreaming {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
        .builder
        .appName("SparkKafkaStreaming")
        .master("local[*]")
        .getOrCreate()
    import spark.implicits._

    val stream = spark.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", "my-cluster-kafka-bootstrap.default.svc:9092") // Change this to your Kafka broker
      .option("subscribe", "cats") // Change this to your Kafka topic
      .option("startingOffsets", "earliest")
      .load()

    val words = stream.selectExpr("CAST(value AS STRING)").as[String]

    val query = words.writeStream
        .outputMode("append")
        .format("console")    // Peut être "parquet", "json", etc
        .option("truncate", false)
        .start()

    val s3Output = words.writeStream
      .format("text")
      .outputMode("append")
      .option("checkpointLocation", "s3a://streaming/checkpoints/")
      .start("s3a://streaming/output/")
    
    query.awaitTermination()
  }
}