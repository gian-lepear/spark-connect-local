FROM apache/spark:4.0.0

ENV SPARK_NO_DAEMONIZE=true \
    SPARK_LOG_DIR=/dev/stdout \
    PYTHONUNBUFFERED=1

USER root

RUN mkdir -p /opt/spark/logs /opt/spark/work /opt/spark/.ivy2/ /opt/spark/data/

RUN chmod -R a+wr /opt/spark/

COPY ./requirements.txt /opt/spark/requirements.txt

RUN pip install -r /opt/spark/requirements.txt && \
    rm /opt/spark/requirements.txt

COPY ./entrypoint.sh /opt/spark/entrypoint.sh

RUN chmod +x /opt/spark/entrypoint.sh

