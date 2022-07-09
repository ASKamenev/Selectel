#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('rabbit', 'otoo=H3A')
connection = pika.BlockingConnection(pika.ConnectionParameters('45.136.180.243', '5672', '/', credentials))
channel = connection.channel()

channel.queue_declare(queue='hello')

channel.basic_publish(exchange='', routing_key='hello', body='Hello World!')
print(" [x] Sent 'Hello World!'")
connection.close()
