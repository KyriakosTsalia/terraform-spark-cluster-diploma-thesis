resource "aws_key_pair" "spark-master-key" {
  key_name   = "spark-master-key"
  public_key = file(var.PATH_TO_SPARK_MASTER_PUBLIC_KEY)
}

resource "aws_key_pair" "spark-worker-key" {
  count      = var.NUMBER_OF_SPARK_WORKERS
  key_name   = format("spark-worker-%02d-key", count.index)
  public_key = file(format(var.PATH_TO_SPARK_WORKER_PUBLIC_KEY, count.index))
}

resource "aws_key_pair" "spark-gateway-key" {
  key_name   = "spark-gateway-key"
  public_key = file(var.PATH_TO_SPARK_GATEWAY_PUBLIC_KEY)
}

resource "aws_key_pair" "prom-graf-key" {
  key_name   = "prom-graf-key"
  public_key = file(var.PATH_TO_PROM_GRAF_PUBLIC_KEY)
}