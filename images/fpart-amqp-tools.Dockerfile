# Specify BROKER_URL and QUEUE when running
FROM doughgle/fpart:v1.2.1

RUN apt-get update && \
    apt-get install -y ca-certificates amqp-tools \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*