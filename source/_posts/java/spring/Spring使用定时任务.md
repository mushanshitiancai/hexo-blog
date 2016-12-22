---
title: Spring使用定时任务
date: 2016-08-05 15:59:20
categories: [Java,Spring]
tags: [java,spring]
---

以前使用PHP的时候，定时脚本都是使用Linux的crontab来执行PHP脚本的。。。比较原始，而且精度是分钟。现在使用Spring了，可以使用Spring的定时任务机制。

Spring中有两种方式来执行定时任务，一个是传统的结合Quartz的做法，一个是3.0之后的@Scheduled注解做法，我们都来看一下。

## 使用注解
Spring3中添加了@Scheduled注解来简化定制任务的配置。只要简单的一个注解就可以实现定时任务，简直简单到爆。

Spring的定时任务的代码集成在context这个核心类库中，所以就不需要引入其他依赖了。

### 开启定时任务
需要在Spring应用上下文中添加配置才能开启后台任务：

```
xmlns:task="http://www.springframework.org/schema/task"
xsi:schemaLocation="http://www.springframework.org/schema/task http://www.springframework.org/schema/task/spring-task.xsd"


<task:annotation-driven />
```

### 注解需要被调度的函数
用Scheduled标注对应的函数，Spring就会按照配置指定执行函数：

```
//每隔一秒执行一次
@Scheduled(fixedRate = 1000)

//距离上次执行完一秒执行一次
@Scheduled(fixedDelay = 1000)

//使用Cron表达式来指定频率
@Scheduled(cron = "1 * * * * ?")
```

最后的Cron表达式类似于Crontab的表达式，不过精确到秒。具体参考：[Cron Expressions][Cron Expressions]

然后就搞定了！简直比Crontab还简单。

## 使用Quartz
除了使用Spring3提供的Scheduled注解，还有一种更传统的做法就是结合使用Quartz这个调度器。这种做法配置量比较大，个人不是很喜欢。

### 添加依赖
Spring在spring-context-support这个库中提供了Quartz的支持，所以需要引入spring-context-support和quartz的依赖：

```
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context-support</artifactId>
    <version>4.3.1.RELEASE</version>
</dependency>
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz</artifactId>
    <version>2.2.1</version>
</dependency>
```

### 定时任务配置
配置分为三个部分，作业类，触发器和调度工厂：

```
<bean id="qtask" class="task.QTask" />

<!-- 配置作业类 -->
<bean id="jobDetail" class="org.springframework.scheduling.quartz.MethodInvokingJobDetailFactoryBean">
    <!-- 指定作业类 -->
    <property name="targetObject" ref="qtask" />
    <!-- 指定作业方法 -->
    <property name="targetMethod" value="task" />
    <!-- 设置是否并发执行作业 -->
    <property name="concurrent" value="true" />
</bean>

<!-- 配置作业调度的方式(触发器) -->
<bean id="triggers" class="org.springframework.scheduling.quartz.CronTriggerFactoryBean">
    <!-- 指定作业 -->
    <property name="jobDetail" ref="jobDetail" />
    <!-- 指定Cron表达式 -->
    <property name="cronExpression" value="* * * * * ?" />
</bean>

<!-- 配置调度工厂 -->
<bean class="org.springframework.scheduling.quartz.SchedulerFactoryBean">
    <!-- 设置调度器开始工作的延迟，单位秒 -->
    <property name="startupDelay" value="10"/>
    <!-- 指定需要触发的触发器 -->
    <property name="triggers">
        <list>
            <ref bean="triggers" />
        </list>
    </property>
</bean>
```

这里重点说一下`concurrent`这个配置，他指定是否可以并发执行任务。比如我设置一秒执行一次任务，但是任务执行一次需要一分钟，那么为了保证没秒都能执行一次任务，Quartz会起新的线程来执行任务。而如果`concurrent`设置为false，那么同时只会有一个任务在执行，即使已经破坏了设置的频率，也保证只有一个任务在执行。

问题：被delay的任务，是被缓存还是被抛弃？
实测：估计是没有“被delay的任务”的概念，如果concurrent=false，那么执行期间不会去触发，执行完成后才会再次开始触发。
测试用例：一个任务第一次执行一分钟，其他执行基本不耗时。cron="*/5 * * * * ?"，第一次执行完毕后，不会一次性打印出多个后续任务，而是再过了5s后打印。

### 任务代码
任务代码就是普通的类了：

```
public class QTask {
    public void task(){
        System.out.println("q task");
    }
}
```

执行程序，载入Spring运行上下文，任务就会被定时执行了。

## 参考资料
- 《Spring实战》
- [Spring定时任务的几种实现 - - ITeye技术网站](http://gong1208.iteye.com/blog/1773177)
- [Spring 4 + Quartz 集成举例 - 推酷](http://www.tuicool.com/articles/beY32i)
- [Cron Expressions][Cron Expressions]
- [在线Cron表达式生成器](http://cron.qqe2.com/)


[Cron Expressions]: https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm