---
title: RabbitMQ消费者是消费一条接收一条还是会被不断推送消息？
date: 2017-12-01 09:21:03
categories: [RabbitMQ]
tags: [architecture,mq]
---

问题：RabbitMQ消费者是消费一条接收一条还是会被不断推送消息？

<!--more-->

实验：

写一个最简单的生产者，一直发消息：

```java
String QUEUE_NAME = "hello";

//建立服务器连接,获取通道
ConnectionFactory factory = new ConnectionFactory();
factory.setHost("cl-dev-rabbitmq-ndss-m98rq6.docker.sdp");
factory.setPort(6055);
factory.setUsername("ndss_dev_nl9EAk");
factory.setPassword("oqENVfQVqOsV");
Connection connection = factory.newConnection();
Channel channel = connection.createChannel();

//声明一个发送队列
//声明一个队列是幂等的，仅仅在要声明的队列不存在时才创建
channel.queueDeclare(QUEUE_NAME, false, false, false, null);


long i = 0;
while (true) {
    String msg = "Hello World!" + i;
    channel.basicPublish("", QUEUE_NAME, null, msg.getBytes());
    System.out.println("Sent msg: " + msg);
    i++;
}
```

写一个消费者，只消费一条消息，并且没有ack：

```java
//建立服务器连接,获取通道
ConnectionFactory factory = new ConnectionFactory();
factory.setHost("cl-dev-rabbitmq-ndss-m98rq6.docker.sdp");
factory.setPort(6055);
factory.setUsername("ndss_dev_nl9EAk");
factory.setPassword("oqENVfQVqOsV");
Connection connection = factory.newConnection();
Channel channel = connection.createChannel();

//声明一个队列
channel.queueDeclare(QUEUE_NAME, false, false, false, null);
System.out.println("Waiting for message...");

//定义一个消费者
QueueingConsumer consumer = new QueueingConsumer(channel);
channel.basicConsume(QUEUE_NAME, false, consumer); // 不自动ACK

//从队列中获取消息并消费一条消息
QueueingConsumer.Delivery delivery = consumer.nextDelivery();
String msg = new String(delivery.getBody());
System.out.println("Received msg: " + msg);

// 没有对消息ACK
//long deliveryTag = delivery.getEnvelope().getDeliveryTag();
//channel.basicAck(deliveryTag, false);
```

观察RabbitMQ的后台，发现Unacked的数目不断增长，说明队列一直在向消费者推消息：

![](/img/mq/a-lot-unack.png)

观察消费者的JVM：

![](/img/mq/jvm-mem-less.png)

可以看到内存不断增长，并触发了GC。不过可以看到GC后内存是得到回收了的，每次不可回收的内存在慢慢增长（因为消息本身很小）。

通过设置prefetch_count可以控制消费者最多有多少条unack的消息，如果消费者对应的unack达到设置的prefetch_count，则服务器不会向这个消费者投递消息。

默认的情况下，prefetch_count为0，也就是不限制。

![](/img/mq/prefetch-count-eq-0.png)

我们可以通过channel.basicQos(1)，设置prefetch_count为1，达到处理完一套消息后，再让服务器推送消息过来。


我们改进一下消费者代码：

```java
//建立服务器连接,获取通道
ConnectionFactory factory = new ConnectionFactory();
factory.setHost("cl-dev-rabbitmq-ndss-m98rq6.docker.sdp");
factory.setPort(6055);
factory.setUsername("ndss_dev_nl9EAk");
factory.setPassword("oqENVfQVqOsV");
Connection connection = factory.newConnection();
Channel channel = connection.createChannel();

//声明一个队列
channel.queueDeclare(QUEUE_NAME, false, false, false, null);
System.out.println("Waiting for message...");

//定义一个消费者
QueueingConsumer consumer = new QueueingConsumer(channel);
channel.basicQos(1); // 一定要写在basicConsume前才能生效
channel.basicConsume(QUEUE_NAME, false, consumer); // 不自动ACK

//从队列中获取消息并消费一条消息
QueueingConsumer.Delivery delivery = consumer.nextDelivery();
String msg = new String(delivery.getBody());
System.out.println("Received msg: " + msg);

// 没有对消息ACK
//long deliveryTag = delivery.getEnvelope().getDeliveryTag();
//channel.basicAck(deliveryTag, false);
```

可以看到Unack的消息只有一条，也就是说RabbitMQ只向消费者推送了一条就停止推送了。

![](/img/mq/unack-eq-1.png)

---

虽然消费者设置了prefetch_count=1，但是内存依然会增长，只是每次gc后基本都gc干净了，为什么？

![](/img/mq/prefetch-count-but-gc.png)

发现只要Connection connection = factory.newConnection()内存就会有慢慢增长，可能和Connection的实现有关系，这个需要看代码才能知道了：

![](/img/mq/new-commection-will-gc.png)

## 参考资料

- [rabbitmq——prefetch count - hncscwc](https://my.oschina.net/hncscwc/blog/195560)
- [RabbitMQ - Consumer Prefetch](http://www.rabbitmq.com/consumer-prefetch.html)