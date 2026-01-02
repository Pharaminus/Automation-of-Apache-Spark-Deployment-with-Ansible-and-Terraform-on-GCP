import org.apache.spark.sql.SparkSession

object WordCount {
  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      println("Usage: WordCount <input_file> <output_dir>")
      System.exit(1)
    }

    val inputFile = args(0)
    val outputDir = args(1)

    val spark = SparkSession.builder()
      .appName("WordCount Application")
      .getOrCreate()

    val sc = spark.sparkContext

    println(s"=== WordCount Starting ===")
    println(s"Input: $inputFile")
    println(s"Output: $outputDir")
    println(s"Executors: ${sc.getExecutorMemoryStatus.size - 1}")

    val startTime = System.currentTimeMillis()

    val textFile = sc.textFile(inputFile)
    val lineCount = textFile.count()
    println(s"Total lines: $lineCount")

    val wordCounts = textFile
      .flatMap(line => line.toLowerCase.split("\\W+"))
      .filter(_.nonEmpty)
      .map(word => (word, 1))
      .reduceByKey(_ + _)
      .sortBy(_._2, ascending = false)

    val uniqueWords = wordCounts.count()
    println(s"Unique words: $uniqueWords")

    wordCounts.saveAsTextFile(outputDir)

    println("\n=== Top 20 Most Frequent Words ===")
    wordCounts.take(20).foreach { case (word, count) =>
      println(f"$word%-20s : $count%6d")
    }

    val endTime = System.currentTimeMillis()
    val duration = (endTime - startTime) / 1000.0

    println(s"\n=== WordCount Completed ===")
    println(f"Execution time: $duration%.2f seconds")
    println(s"Output saved to: $outputDir")

    spark.stop()
  }
}