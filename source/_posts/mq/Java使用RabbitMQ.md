---
title: Java使用RabbitMQ
date: 2016-08-08 15:00:43
categories: [RabbitMQ]
tags: [architecture,mq]
---

<!-- more -->

## 安装RabbitMQ

```
$ brew install rabbitmq
```

默认rabbit的命令会被安装到/usr/local/sbin下，这个路径默认不在PATH中，你需要手动添加一下。

启动rabbitmq的方法有两种，一种是使用brew命令：

```
$ brew services start rabbitmq
```

或者手动启动

```
$ rabbitmq-server
```

默认rabbitmq会建立一个guest用户，密码也是guest，这个用户只能从localhost访问。这个对于我们用于测试学习是够了，如果要建立可以被远程访问的rabbitmq，可以参考[access control](https://www.rabbitmq.com/access-control.html)。

可以访问rabbitmq自带的管理后台查看其运行状态：

![](/img/architecture/rabbitmq-admin.png)

## Java使用RabbitMQ 
### 添加依赖

```
<dependency>
    <groupId>com.rabbitmq</groupId>
    <artifactId>amqp-client</artifactId>
    <version>3.6.5</version>
</dependency>
```

### 编写发送方

```
public class Send {
    public static final String QUEUE_NAME = "hello";

    public static void main(String[] args) throws IOException, TimeoutException {

        //建立服务器连接,获取通道
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("localhost");
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

        //声明一个发送队列
        //声明一个队列是幂等的，仅仅在要声明的队列不存在时才创建
        channel.queueDeclare(QUEUE_NAME,false,false,false,null);
        String msg = "Hello World!";
        channel.basicPublish("",QUEUE_NAME,null,msg.getBytes());
        System.out.println("Sent msg: "+msg);

        //关闭通道和连接
        channel.close();
        connection.close();
    }
}
```

### 编写接收方

```
public class Recv {
    public static final String QUEUE_NAME = "hello";

    public static void main(String[] args) throws IOException, TimeoutException, InterruptedException {
        //建立服务器连接,获取通道
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("localhost");
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

        //声明一个队列
        channel.queueDeclare(QUEUE_NAME,false,false,false,null);
        System.out.println("Waiting for message...");

        //定义一个消费者
        QueueingConsumer consumer = new QueueingConsumer(channel);
        channel.basicConsume(QUEUE_NAME,true,consumer);

        //从队列中获取消息并消费
        while (true){
            QueueingConsumer.Delivery delivery = consumer.nextDelivery();
            String msg = new String(delivery.getBody());
            System.out.println("Received msg: "+msg);
        }
    }
}
```

### 继续学习
RabbitMQ官网的教程写得非常好，图文并茂，推荐阅读：[RabbitMQ - Getting started with RabbitMQ](https://www.rabbitmq.com/getstarted.html)

## RabbitMQ技巧
### 在命令行中查看队列消息

```
$ rabbitmqadmin get queue=hello requeue=false
```

参考：[RabbitMQ - Management Command Line Tool][RabbitMQ - Management Command Line Tool]

### 使用rabbitmq_tracing插件记录消息收发日志

```
$ rabbitmq-plugins enable rabbitmq_tracing
```

然后RabbitMQ Management管理后台中就可以看日志了：

![](http://images0.cnblogs.com/blog/35158/201505/201550452754051.png)

（图片引用自，http://www.cnblogs.com/gossip/p/4517345.html）

## 参考资料
- [RabbitMQ - Installing on Homebrew](https://www.rabbitmq.com/install-homebrew.html)
- [RabbitMQ入门（1）--介绍 - 悟空的日记簿 - 开源中国社区](http://my.oschina.net/OpenSourceBO/blog/379732)
- [RabbitMQ入门（2）--工作队列 - 悟空的日记簿 - 开源中国社区](http://my.oschina.net/OpenSourceBO/blog/379735)
- [MAC OS X 安装、配置、启动 rabbitMQ - 霖_柒 的个人空间 - 开源中国社区](http://my.oschina.net/u/998693/blog/547873)
- [rabbitmq记录收发的消息体日志信息 - sdaiweiy的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/sdaiweiy/article/details/46786109)
- [消息队列系列（三）：.Rabbitmq Trace的使用 - 扯 - 博客园](http://www.cnblogs.com/gossip/p/4517345.html)

[RabbitMQ - Management Command Line Tool]: http://www.rabbitmq.com/management-cli.html