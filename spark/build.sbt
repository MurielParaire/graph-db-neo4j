name := "Simple Project"

version := "1.0"

scalaVersion := "2.12.18"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.5.5"
libraryDependencies += "org.neo4j" %% "neo4j-connector-apache-spark" % "5.3.1_for_spark_3"
libraryDependencies += "org.mongodb.spark" %% "mongo-spark-connector" % "10.4.0"
libraryDependencies += "org.apache.spark" % "spark-streaming_2.12" % "3.5.5" % "provided"


Compile / mainClass := Some("fr.umontpellier.polytech.SparkMinIOStreaming")