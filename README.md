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
pip install apache-flink kafka-python faker json
```
# Usage
```
docker exec -it <container id> bash
```
```
bin/sql-client.sh
```

