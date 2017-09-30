---
title: 压力测试工具ab学习笔记
date: 2016-07-01 15:18:28
categories:
tags: test
---

ab是Apache服务器自带的一个压力测试工具，用户测试HTTP服务器的性能。

<!-- more -->

## 安装

ab是附带在Apache服务器中的一个工具，所以我们要安转Apache。Windows下安装可以参考[如何从Apache官网下载windows版apache服务器](https://jingyan.baidu.com/article/29697b912f6539ab20de3cf8.html)

## 使用

最简单的用法：

    ab -n 10 -c 2 http://www.baidu.com/

`-n 10`指总共请求10次，`-c 2`指开启2个线程执行请求。

请求完毕后，ab会生成一段报文：

```
This is ApacheBench, Version 2.3 <$Revision: 1663405 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.baidu.com (be patient).....done


Server Software:        BWS/1.1          # 响应报文中的Server字段
Server Hostname:        www.baidu.com    # 从命令行中提取的主机地址
Server Port:            80               # 请求的端口号

Document Path:          /                # 从命令行中提取的页面地址
Document Length:        99195 bytes      # 第一个响应报文的长度
                                         # 如果之后的报文长度不一致，认为失败

Concurrency Level:      2                # 处理测试的线程数
Time taken for tests:   0.191 seconds    # 耗时
Complete requests:      10               # 完成的请求数
Failed requests:        8                # 失败的请求数，括号里写出了失败的原因
   (Connect: 0, Receive: 0, Length: 8, Exceptions: 0)
Total transferred:      1003686 bytes    # 总共传输的字节数
HTML transferred:       993790 bytes     # 总共传输的字节数，不包含头部
Requests per second:    52.38 [#/sec] (mean)   # 吞吐量
                                               # 最重要的字段，表示一秒处理的请求数
Time per request:       38.182 [ms] (mean)     # 每个请求处理的时间
Time per request:       19.091 [ms] (mean, across all concurrent requests)
Transfer rate:          5134.21 [Kbytes/sec] received  # 传输速率

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        4    6   2.1      5      10
Processing:    22   31   9.8     29      50
Waiting:        5   11   6.6      9      27
Total:         28   37   9.9     34      59

Percentage of the requests served within a certain time (ms)
  50%     34
  66%     35
  75%     36
  80%     52
  90%     59
  95%     59
  98%     59
  99%     59
 100%     59 (longest request)
```

### 参考地址
- [ab - Apache HTTP server benchmarking tool - Apache HTTP Server Version 2.4](https://httpd.apache.org/docs/2.4/programs/ab.html)
- [apache自带的ab压力测试工具用法详解 - hytfly的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/hytfly/article/details/8964963)