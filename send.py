#!/usr/bin/env python
import pika
count = 0
while count <= 10:
  credentials = pika.PlainCredentials('rabbit', '768a852ed69ce916fa7faa278c962de3e4275e5f')
  connection = pika.BlockingConnection(pika.ConnectionParameters('45.136.180.132', '5672', '/', credentials))
  channel = connection.channel()

  channel.queue_declare(queue='hello')


  channel.basic_publish(exchange='', routing_key='hello', body='Hello World!')
  print(" [x] Sent 'Hello World!'")
  count +=1
connection.close()
