---
title: 阿里消息中间件RocketMQ学习笔记
date: 2016-08-11 11:06:29
categories:
tags: [architecture,mq]
---

开始的开始，我先来吐槽一下这个RocketMQ，既然是开源项目，代码质量自不用说，但是文档也是很重要的，RocketMQ的文档首页竟然只有一则招聘广告。。。

## 安装运行

```
git clone https://github.com/alibaba/RocketMQ.git
cd RocketMQ
sh install.sh
```

把RocketMQ的目录放入你的bash_profile或者zsh_profile中：

```
echo "ROCKETMQ_HOME=`pwd`" >> ~/.bash_profile
source ~/.bash_profile
```

然后启动Name Server：

```
cd devenv/bin
sh mqnamesrv
```

Name Server会运行在9876端口上。然后我们启动Broker，我们这里只启动一个Broker，也就是单Master模式：

```
sh mqbroker -n localhost:9876

输出：
The broker[mazhibindeMacBook-Pro.local, 172.28.0.118:10911] boot success. serializeType=JSON and name server is localhost:9876
```

Broker的日志可以在`~/logs/rocketmqlogs/broker.log`中查看。

这样就可以开始编写生产者和消费者的代码了。RocketMQ提供了测试的工具，可以快速发送消息和接受消息：

```
export NAMESRV_ADDR=localhost:9876

# 发送消息
sh tools.sh com.alibaba.rocketmq.example.quickstart.Producer

# 接受消息
sh tools.sh com.alibaba.rocketmq.example.quickstart.Consumer
```

如果你看到很多输出，说明安装成功了。

## 编写生产者和消费者

添加依赖

```
<dependency>
    <groupId>com.alibaba.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>3.5.5</version>
</dependency>
```

生产者：

```
public class Producer {

    public static void main(String[] args) {
        DefaultMQProducer producer = new DefaultMQProducer("Producer");
        producer.setNamesrvAddr("localhost:9876");

        try {
            producer.start();

            Message msg = new Message("PushTopic","push","1","Just for test".getBytes());

            SendResult result = producer.send(msg);
            System.out.println(result.toString());

        } catch (MQClientException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (RemotingException e) {
            e.printStackTrace();
        } catch (MQBrokerException e) {
            e.printStackTrace();
        }
    }
}
```

消费者：

```
public class Consumer {

    public static void main(String[] args) {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("PushConsumer");
        consumer.setNamesrvAddr("localhost:9876");

        try {
            consumer.subscribe("PushTopic", "push");

            consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);
            consumer.registerMessageListener(
                    new MessageListenerConcurrently() {
                        public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                            Message msg = list.get(0);
                            System.out.println(msg);
                            return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
                        }
                    }
            );
            consumer.start();
        } catch (MQClientException e) {
            e.printStackTrace();
        }

    }
}
```

启动生产者，输出：

```
SendResult [sendStatus=SEND_OK, msgId=AC1C007620F629453F44340972120000,offsetMsgId=AC1C007600002A9F0000000000021AA2, messageQueue=MessageQueue [topic=PushTopic, brokerName=mazhibindeMacBook-Pro.local, queueId=1], queueOffset=0]
```

启动消费者输出：

```
MessageExt [queueId=1, storeSize=182, queueOffset=0, sysFlag=0, bornTimestamp=1470897034259, bornHost=/172.28.0.118:50525, storeTimestamp=1470897034305, storeHost=/172.28.0.118:10911, msgId=AC1C007600002A9F0000000000021AA2, commitLogOffset=137890, bodyCRC=1001808822, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message [topic=PushTopic, flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=1, KEYS=1, CONSUME_START_TIME=1470897111881, UNIQ_KEY=AC1C007620F629453F44340972120000, WAIT=true, TAGS=push}, body=13]]
```


## 参考资料
- [阿里RocketMQ Quick Start - 怀揣梦想，努力前行 - 博客频道 - CSDN.NET](http://blog.csdn.net/a19881029/article/details/34446629)
- [Quick Start · alibaba/RocketMQ Wiki](https://github.com/alibaba/RocketMQ/wiki/Quick-Start)
- [RocketMQ快速入门 | krisjin博客](http://krisjin.github.io/2015/06/03/rocketmq-start/)