#!/bin/bash

# List kafka topics
kafka-topics.sh --list --bootstrap-server localhost:9092

# If you are using Kafka 2.2.0 or later, you can also use the following command to list Kafka topics:
kafka-admin --bootstrap-server localhost:9092 list-topics

# List topic information
kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic my-topic
