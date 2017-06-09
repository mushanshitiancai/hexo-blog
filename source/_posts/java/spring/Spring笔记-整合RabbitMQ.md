---
title: Spring笔记-整合RabbitMQ
date: 2016-08-08 11:29:28
categories: [Java,Spring]
tags: [java,spring]
---

<!-- more -->

## 引入依赖

```
<dependencies>
    <dependency>
        <groupId>org.springframework.amqp</groupId>
        <artifactId>spring-rabbit</artifactId>
        <version>1.6.1.RELEASE</version>
    </dependency>
</dependencies>
```

## 编写消费者
消费者是一个非常非常普通的类：

```
public class Consumer {

    public void listen(String foo){
        System.out.println(foo);
    }
}
```

## 编写Spring运行上下文配置

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rabbit="http://www.springframework.org/schema/rabbit"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/rabbit http://www.springframework.org/schema/rabbit/spring-rabbit.xsd">

    <rabbit:connection-factory id="connectionFactory" host="localhost" />

    <rabbit:admin connection-factory="connectionFactory" />

    <rabbit:queue name="myQueue" />

    <rabbit:topic-exchange name="myExchange">
        <rabbit:bindings>
            <rabbit:binding queue="myQueue" pattern="fooz.*" />
        </rabbit:bindings>
    </rabbit:topic-exchange>

    <rabbit:template id="rabbitTemplate" connection-factory="connectionFactory"
                     exchange="myExchange" routing-key="foo.bar" />

    <rabbit:listener-container connection-factory="connectionFactory">
        <rabbit:listener ref="consumer" method="listen" queue-names="myQueue" />
    </rabbit:listener-container>

    <bean id="consumer" class="com.mushan.rabbit.spring.Consumer" />
</beans>
```

## 编写主程序

```
public class Main {

    public static void main(String[] args) throws InterruptedException {
        AbstractApplicationContext ctx = new ClassPathXmlApplicationContext("/spring.xml");

        //获取RabbitTemplate,用于发送消息
        RabbitTemplate rabbitTemplate = ctx.getBean(RabbitTemplate.class);
        rabbitTemplate.convertAndSend("@Hello World@");

        
        Thread.sleep(1000);
        ctx.destroy();
    }
}
```


## 参考资料
- [spring整合消息队列rabbitmq - Fe的一亩三分地 - 开源中国社区](http://my.oschina.net/never/blog/140368)