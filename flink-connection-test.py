import configparser
from confluent_kafka.admin import AdminClient

config = configparser.ConfigParser()
config.read('config.ini')
bootstrap_server = config['kafka']['bootstrap_server']
key = config['kafka']['key']
secret = config['kafka']['secret']

conf = {
    "bootstrap.servers": bootstrap_server,
    "sasl.mechanism": "PLAIN",
    "security.protocol": "SASL_SSL",
    "sasl.username": key,
    "sasl.password": secret
}

a = AdminClient(conf)
metadata = a.list_topics(timeout=5)

print("Available Topics:")
for topic in metadata.topics:
    print(f" - {topic}")