import json
import configparser
from confluent_kafka import Producer
from confluent_kafka.admin import AdminClient, NewTopic, KafkaException

# Load configuration
config = configparser.ConfigParser()
config.read('config.ini')
bootstrap_server = config['kafka']['bootstrap_server']
key = config['kafka']['key']
secret = config['kafka']['secret']

# Kafka AdminClient Configuration
admin_client = AdminClient({
    'bootstrap.servers': bootstrap_server,
    # not used on localhost
    'security.protocol': 'SASL_SSL',
    'sasl.mechanism': 'PLAIN',
    'sasl.username': key,
    'sasl.password': secret
})

# Kafka Producer Configuration
producer = Producer({
    'bootstrap.servers': bootstrap_server,
    # not used on localhost
    'security.protocol': 'SASL_SSL',
    'sasl.mechanism': 'PLAIN',
    'sasl.username': key,
    'sasl.password': secret
})

# Target topic
target_topic = 'rides-input'

# Ensure topic exists
def ensure_topic_exists(topic_name):
    metadata = admin_client.list_topics(timeout=10)
    if topic_name in metadata.topics:
        print(f"Topic '{topic_name}' already exists.")
    else:
        print(f"Creating topic '{topic_name}'...")
        new_topic = NewTopic(topic=topic_name, num_partitions=1, replication_factor=3)
        try:
            admin_client.create_topics([new_topic])
            print(f"Topic '{topic_name}' created.")
        except KafkaException as e:
            print(f"Failed to create topic: {e}")

# Delivery report callback
def delivery_report(err, msg):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(f"Delivered to {msg.topic()} [{msg.partition()}]")

# Read from JSON file and send to Kafka
def produce_from_file(file_path):
    ensure_topic_exists(target_topic)
    with open(file_path, 'r') as f:
        for line in f:
            try:
                record = json.loads(line.strip())
                producer.produce(
                    target_topic,
                    value=json.dumps(record),
                    callback=delivery_report
                )
                producer.poll(0)
            except Exception as e:
                print(f"Skipped line: {e}")
    producer.flush()
    print("All messages sent.")

if __name__ == "__main__":
    produce_from_file("nyc_taxi_sample.json")
