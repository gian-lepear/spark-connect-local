#!/bin/bash
set -euo pipefail

export SPARK_CONNECT_EXECUTORS_MEMORY=${SPARK_CONNECT_EXECUTORS_MEMORY:-1g}
export SPARK_CONNECT_EXECUTORS_CORE=${SPARK_CONNECT_EXECUTORS_CORE:-1}
export SPARK_CONNECT_NUM_EXECUTORS=${SPARK_CONNECT_NUM_EXECUTORS:-1}

# Define Spark packages
packages=(
  "org.apache.spark:spark-connect_2.13:4.0.0"
  "org.apache.hadoop:hadoop-aws:3.4.1"
  "org.apache.hadoop:hadoop-common:3.4.1"
  "com.databricks:spark-xml_2.13:0.18.0"
)

# Convert the list to a comma-separated string
packages_string=$(IFS=,; echo "${packages[*]}")

# Start Spark Master in the background
/opt/spark/sbin/start-master.sh &

# Wait for Spark Master to become available
echo "Waiting for Spark Master at http://master:8080..."
until curl -sSf "http://master:8080" >/dev/null; do
  sleep 1
done

echo "Spark Master is ready. Starting Spark Connect with packages:"
echo "$packages_string"

# Launch Spark Connect with the specified configuration
exec /opt/spark/sbin/start-connect-server.sh --packages "$packages_string" \
  --conf "spark.hadoop.fs.s3a.access.key=${AWS_ACCESS_KEY_ID}" \
  --conf "spark.hadoop.fs.s3a.secret.key=${AWS_SECRET_ACCESS_KEY}" \
  --conf "spark.hadoop.fs.s3a.endpoint=${AWS_ENDPOINT}" \
  --conf "spark.hadoop.fs.s3a.path.style.access=true" \
  --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false" \
  --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
  --conf spark.executor.memory="${SPARK_CONNECT_EXECUTORS_MEMORY:-1g}" \
  --conf spark.executor.cores="${SPARK_CONNECT_EXECUTORS_CORE:-1}" \
  --num-executors "${SPARK_CONNECT_NUM_EXECUTORS:-1}"
