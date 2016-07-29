---
title: 搭建dubbo+zookeeper+spring环境-环境篇
date: 2016-07-29 18:54:33
categories: [Java]
tags: [java,dubbo]
---

环境：mac，Java8，tomcat8

## 安装zookeeper

安装zookeeper

    brew install zookeeper

zookeeper的配置文件在`/usr/local/etc/zookeeper/zoo.cfg`

启动zookeeper

    brew services start zookeeper


## 编译dubbo

下载dubbo源码：

```
git clone https://github.com/alibaba/dubbo.git
cd dubbo
git co dubbo-2.5.3
mvn clean install -Dmaven.test.skip
```

提示错误：

```
[INFO] Scanning for projects...
Downloading: http://code.alibabatech.com/mvn/releases/com/alibaba/opensesame/2.0/opensesame-2.0.pom
[ERROR] [ERROR] Some problems were encountered while processing the POMs:
[FATAL] Non-resolvable parent POM for com.alibaba:dubbo-parent:2.5.3: Could not transfer artifact com.alibaba:opensesame:pom:2.0 from/to opensesame.releases (http://code.alibabatech.com/mvn/releases): Connect to code.alibabatech.com:80 [code.alibabatech.com/119.38.217.15] failed: 
```

发现[](http://code.alibabatech.com)这丫的域名根本就挂了。。。参考[dubbo实践（二）自己动手编译源码][dubbo实践（二）自己动手编译源码]，这里我们需要自己安装opensesame这个项目：

```
git clone https://github.com/alibaba/opensesame.git
cd opensesame
mvn install
```

然后再进入dubbo目录下执行`mvn clean install -Dmaven.test.skip`还是提示错误：

```
[ERROR] Failed to execute goal on project dubbo-common: Could not resolve dependencies for project com.alibaba:dubbo-common:jar:2.5.3: Failed to collect dependencies at com.alibaba:fastjson:jar:1.1.8: Failed to read artifact descriptor for com.alibaba:fastjson:jar:1.1.8: Could not transfer artifact com.alibaba:fastjson:pom:1.1.8 from/to opensesame.releases (http://code.alibabatech.com/mvn/releases): Connect to code.alibabatech.com:80 [code.alibabatech.com/119.38.217.15] failed: Connection refused -> [Help 1]
```

这是因为opensesame的pom指定了去阿里的仓库上下载，而阿里的仓库现在挂了，所以，修改opensesame的pom文件，注释掉repositories，distributionManagement，pluginRepositories这些标签。还得注释dubbo-parent的pom.xml中的repositories标签。

再次install还是失败。。说com.alibaba:fastjson:pom:1.1.8找不到。上mvnrepository看一下，发现maven仓库上根本就没有这个版本。。。修改dubbo-parent的pom.xml的`<fastjson_version>1.1.8</fastjson_version>`为`<fastjson_version>1.1.15</fastjson_version>`

再次install终于成功。

## 运行dubbo控制台

```
cd dubbo/dubbo-admin
mvn jetty:run -Ddubbo.registry.address=zookeeper://127.0.0.1:2181
```

遇到错误：

```
ERROR context.ContextLoader - Context initialization failed
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'uriBrokerService': Cannot create inner bean '(inner bean)' of type [com.alibaba.citrus.service.uribroker.impl.URIBrokerServiceImpl$URIBrokerInfo] while setting bean property 'brokers' with key [0]; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name '(inner bean)#25': Cannot create inner bean 'server' of type [com.alibaba.citrus.service.uribroker.uri.GenericURIBroker] while setting constructor argument; nested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'server': Error setting property values; nested exception is org.springframework.beans.NotWritablePropertyException: Invalid property 'URIType' of bean class [com.alibaba.citrus.service.uribroker.uri.GenericURIBroker]: Bean property 'URIType' is not writable or has an invalid setter method. Does the parameter type of the setter match the return type of the getter?
```

参考：[2.5.4-SNAPSHOT dubbo admin error · Issue #50 · alibaba/dubbo](https://github.com/alibaba/dubbo/issues/50)，修改如下：

1、webx的依赖改为3.1.6版；

    <dependency>
        <groupId>com.alibaba.citrus</groupId>
        <artifactId>citrus-webx-all</artifactId>
        <version>3.1.6</version>
    </dependency>

2、添加velocity的依赖，我用了1.7；

    <dependency>
        <groupId>org.apache.velocity</groupId>
        <artifactId>velocity</artifactId>
        <version>1.7</version>
    </dependency>

3、对依赖项dubbo添加exclusion，避免引入旧spring

    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>dubbo</artifactId>
        <version>${project.parent.version}</version>
        <exclusions>
            <exclusion>
                <groupId>org.springframework</groupId>
                <artifactId>spring</artifactId>
            </exclusion>
        </exclusions>
    </dependency>

4、webx已有spring 3以上的依赖，因此注释掉dubbo-admin里面的spring依赖

    <!--<dependency>-->
        <!--<groupId>org.springframework</groupId>-->
        <!--<artifactId>spring</artifactId>-->
    <!--</dependency>-->

再次运行，错误：

```
[ERROR] Failed to execute goal org.mortbay.jetty:maven-jetty-plugin:6.1.26:run (default-cli) on project dubbo-admin: Failure: Address already in use -> [Help 1]
```

修改POM：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.mortbay.jetty</groupId>
            <artifactId>maven-jetty-plugin</artifactId>
            <version>${jetty_version}</version>
            <configuration>
                <contextPath>/</contextPath>
                <scanIntervalSeconds>10</scanIntervalSeconds>
                <connectors>
                    <connector implementation="org.mortbay.jetty.nio.SelectChannelConnector">
                        <port>8081</port>
                        <maxIdleTime>60000</maxIdleTime>
                    </connector>
                </connectors>
            </configuration>
        </plugin>
    </plugins>
</build>
```

把原来的8080修改为8081。范围http://localhost:8081/即可看到dubbo控制台。

成功。

如果你和我一样遇到错误，打开一个服务，页面显示404，同时报错：

```
INFO interceptor.RestfuleUrlRewriter -  [DUBBO] REWRITE restful uri /governance/services to uri governance/services.htm?{_type=services, _path=governance/services}, dubbo version: 2.5.4-SNAPSHOT, current host: 192.168.33.1
 INFO interceptor.AuthorizationValve -  [DUBBO] AuthorizationValve of uri: /governance/services, dubbo version: 2.5.4-SNAPSHOT, current host: 192.168.33.1
 INFO interceptor.RestfuleUrlRewriter -  [DUBBO] REWRITE restful uri /governance/services/DemoServer/providers to uri governance/services.htm?{_method=DemoServer/providers, _type=services, _path=governance/services/DemoServer/providers}, dubbo version: 2.5.4-SNAPSHOT, current host: 192.168.33.1
 INFO interceptor.AuthorizationValve -  [DUBBO] AuthorizationValve of uri: /governance/services/DemoServer/providers, dubbo version: 2.5.4-SNAPSHOT, current host: 192.168.33.1
ERROR valve.HandleExceptionValve - Failed to process request /governance/services/DemoServer/providers, the root cause was TemplateNotFoundException: Could not find template "/screen/services"
com.alibaba.citrus.service.pipeline.PipelineException: Failed to invoke Valve[#3/3, level 3]: com.alibaba.citrus.turbine.pipeline.valve.RenderTemplateValve#7f1581bb:RenderTemplateValve
```

说明你暴露了一个顶级包下的接口类似于`DemoServer`，如果你暴露的是`com.xx.DemoServer`就不会有这个问题。这个应该是dubbo的一个bug。

环境搭建好了，接下来我们写一个简单的服务提供者和服务消费者的例子。请看

## 参考资料
- [Dubbo与Zookeeper、SpringMVC整合和使用（负载均衡、容错） - 在前进的路上 - 博客频道 - CSDN.NET](http://blog.csdn.net/congcong68/article/details/41113239)
- [dubbo实践（二）自己动手编译源码][dubbo实践（二）自己动手编译源码]
- [alibaba/dubbo: Dubbo is a distributed, high performance RPC framework enpowering applications with service import/export capabilities.](https://github.com/alibaba/dubbo)
- [2.5.4-SNAPSHOT dubbo admin error · Issue #50 · alibaba/dubbo](https://github.com/alibaba/dubbo/issues/50)
- [code.alibabatech.com不能访问了，是阿里不让用了吗 · Issue #22 · alibaba/dubbo](https://github.com/alibaba/dubbo/issues/22)


[dubbo实践（二）自己动手编译源码]: http://www.cnblogs.com/pengkw/p/3674730.html