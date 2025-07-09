import json
from pathlib import Path

from pyspark.sql import SparkSession
from pyspark.sql.dataframe import DataFrame
from pyspark.sql.types import StructType

LOCAL_DIR = "data"
SPARK_DATA_DIR = Path("/opt/spark/data")

spark: SparkSession = (
    SparkSession.builder.appName("Spark Connect Test")  # type: ignore
    .remote("sc://localhost")  # or sc://localhost:15002
    .getOrCreate()
)

# Read XML sample data
df: DataFrame = (
    spark.read.format("com.databricks.spark.xml")
    .options(rowTag="DadosEconomicoFinanceiros")
    .load(f"{SPARK_DATA_DIR.as_uri()}/sample")
)
# Write data as parquet
df.repartition(4).write.parquet(
    path=f"{SPARK_DATA_DIR}/rendimentos",
    compression="snappy",
    mode="overwrite",
)

# Read parquet data
json_schema = json.loads(df.schema.json())
schema = StructType.fromJson(json_schema)

df_parquet: DataFrame = (
    spark.read.format("parquet").schema(schema).load(f"{SPARK_DATA_DIR}/rendimentos")
)
df_parquet.show()
df_parquet.printSchema()
