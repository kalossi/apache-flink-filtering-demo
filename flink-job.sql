-- Use Flink-sql-cli to excute jobs
-- Create a Kafka source to read data from the rides-input topic
CREATE TABLE rides_input (
    vendor_id INT,
    pickup_datetime STRING,
    dropoff_datetime STRING,
    passenger_count INT,
    trip_distance DOUBLE,
    fare_amount DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'rides-input',
    'properties.bootstrap.servers' = 'pkc-zm3p0.eu-north-1.aws.confluent.cloud:9092',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.username' = '<your-api-key>',
    'properties.sasl.password' = '<your-api-secret>',
    'format' = 'json',
    'scan.startup.mode' = 'earliest-offset'
);

-- Filter rides based on trip distance: short and long
CREATE VIEW short_rides AS
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount
FROM rides_input
WHERE trip_distance > 0 AND trip_distance <= 5 AND passenger_count > 0;

CREATE VIEW long_rides AS
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount
FROM rides_input
WHERE trip_distance > 5 AND passenger_count > 0;

-- Create Kafka sinks for the short-rides and long-rides topics
CREATE TABLE short_rides_output (
    vendor_id INT,
    pickup_datetime STRING,
    dropoff_datetime STRING,
    passenger_count INT,
    trip_distance DOUBLE,
    fare_amount DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'short-rides',
    'properties.bootstrap.servers' = 'pkc-zm3p0.eu-north-1.aws.confluent.cloud:9092',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.username' = '<your-api-key>',
    'properties.sasl.password' = '<your-api-secret>',
    'format' = 'json'
);

CREATE TABLE long_rides_output (
    vendor_id INT,
    pickup_datetime STRING,
    dropoff_datetime STRING,
    passenger_count INT,
    trip_distance DOUBLE,
    fare_amount DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'long-rides',
    'properties.bootstrap.servers' = 'pkc-zm3p0.eu-north-1.aws.confluent.cloud:9092',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.username' = '<your-api-key>',
    'properties.sasl.password' = '<your-api-secret>',
    'format' = 'json'
);

-- Insert filtered results into the short-rides and long-rides topics
INSERT INTO short_rides_output
SELECT * FROM short_rides;

INSERT INTO long_rides_output
SELECT * FROM long_rides;
