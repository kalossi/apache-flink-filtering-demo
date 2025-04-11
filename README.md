# Prerequsities
```
mkdir flink-venv && cd flink-venv
```
Create python virtual environment
```
python -m venv venv
```
Activate the virtual environment
```
venv\Scripts\activate
```
Install dependencies
```
pip install kafka-python json
```
# Usage
Remember to add your correct bootstrap server endpoint!!!

You also need jaas.conf file in the format of:
```
KafkaClient {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="api-key"
    password="api-secret";
};
```
```
docker-compose up --build -d
```
```
docker exec -it <container id> bash
```
Start the flinkSQL inside the container:
```
bin/sql-client.sh
```
Start your Flink jobs from sql

Then produce your topic:
```
python produce.py
```

