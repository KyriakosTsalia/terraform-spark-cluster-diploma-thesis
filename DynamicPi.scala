/*
 * Based on the SparkPi example found here:
 * https://github.com/apache/spark/blob/master/examples/src/main/scala/org/apache/spark/examples/SparkPi.scala
 * 
 * This example computes an approximation of pi, sleeps for 1 minute and the recomputes it again.
 * Use it to monitor Spark's dynamic resource allocation, experiment with the parameters offered
 * to customize the resource request and remove policies and understand their effects, both on the 
 * execution of the application and the state of the cluster, as far as multitenancy and resource
 * waste are concerned.
 */

import scala.math.random
import org.apache.spark.sql.SparkSession

object DynamicPi extends App {

  val spark = SparkSession.builder()
    .appName("Dynamic Pi")
    .getOrCreate()

  def SparkPi(sparkSession: SparkSession): Unit = {
    val slices = if (args.length > 0) args(0).toInt else 2
    val n = math.min(100000L * slices, Int.MaxValue).toInt // avoid overflow
    val count = sparkSession.sparkContext.parallelize(1 until n, slices).map { i =>
      val x = random * 2 - 1
      val y = random * 2 - 1
      if (x*x + y*y <= 1) 1 else 0
    }.reduce(_ + _)
    println(s"Pi is roughly ${4.0 * count / (n - 1)}")
  }

  SparkPi(spark)
  Thread.sleep(60000) // wait for 1 minute
  SparkPi(spark)

  spark.stop()
}