---
title: CURL笔记-基本使用
date: 2018-02-27 11:52:12
categories:
tags: [curl]
toc: true
---

CURL命令行使用笔记。

<!-- more -->

## 注意事项

1. 网址需要用引号扩起来，否则其中的一些字符串（比如`&`）会被Bash解析掉

## 设置请求方法

- 默认是GET方法
- 设置为HEAD方法 `-I, --head`
- 设置为特定方法 `-X, --request <command>`

## 设置Header

- 设置头部 `-H, --header <header>` 
- 设置`User-Agent`头部 `-A, --user-agent <agent string>` 
- 设置`Cookie`头部 `-b, --cookie <name=data>` 
- 设置`Referer`头部 `-e, --referer <URL>` 

```
$ curl -H 'Host: 111.111.11.11'-H 'Accept-Language: es' http://test.com
```

## 设置请求体

- `-d, --data <data>` 设置请求体。
- `--data-ascii <data>` `-d, --data`的别名
- `--data-binary <data>` 与与`-d, --data`类似，如果以`@`开头，则后面必须跟着文件名，并且文件中的换行符，回车符会保留，也不会做其他的转换
- `--data-raw <data>` 与`-d, --data`类似，只是不会处理参数中的`@`符号
- `--data-urlencode <data>`

需要注意，`--data`系列参数会把请求的`Content-Type`设置为`application/x-www-form-urlencoded`。

- `-F, --form <name=content>` 设置表单内容，可以让curl发送和网页中表单一样的请求体，可以用来上传文件，
`Content-Type`头部会被设置为`multipart/form-data`。

需要注意，`--data`系列参数和`-F`参数都会让请求方法变为POST。

设置请求体是curl中比较复杂的操作，这里做了几个实验：

`test.txt`的内容为：

```
123
456
```

`@`开头加文件名会让curl使用文件内容。`--data`默认会去掉回车和换行：

```
$ curl --data "@test.txt" 'http://localhost:8080/upload'

POST /upload HTTP/1.1
Host: localhost:8080
User-Agent: curl/7.54.0
Accept: */*
Content-Length: 6
Content-Type: application/x-www-form-urlencoded

123456
```

`--data-binary`不会去掉文件中的回车和换行:

```
$ curl --data-binary "@test.txt" 'http://localhost:8080/upload'

POST /upload HTTP/1.1
Host: localhost:8080
User-Agent: curl/7.54.0
Accept: */*
Content-Length: 8
Content-Type: application/x-www-form-urlencoded

123
456
```

`--data-raw`则不会去解析`@`:

```
$ curl --data-raw "@test.txt" 'http://localhost:8080/upload'

POST /upload HTTP/1.1
Host: localhost:8080
User-Agent: curl/7.54.0
Accept: */*
Content-Length: 9
Content-Type: application/x-www-form-urlencoded

@test.txt
```

`--data`不会对参数进行url编码：

```
$ curl --data "你" 'http://localhost:8080/upload'

POST /upload HTTP/1.1
Host: localhost:8080
User-Agent: curl/7.54.0
Accept: */*
Content-Length: 2
Content-Type: application/x-www-form-urlencoded

..
```

这里的`..`其实是`你`这个字的原始编码：

![](/img/tools/curl-not-urlencode-body.png)

`--data-urlencode`会对参数进行url编码：

```
$ curl --data-urlencode "你" 'http://localhost:8080/upload'

POST /upload HTTP/1.1
Host: localhost:8080
User-Agent: curl/7.54.0
Accept: */*
Content-Length: 6
Content-Type: application/x-www-form-urlencoded

%C4%E3
```

一个常见的需求，我们怎么用curl发送JSON请求呢？

```
$ curl -H "Content-Type: application/json" -X POST -d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login
```

## 控制输出

- 在输出中包含Header信息 `-i, --include`（和`-I`要区分开，后者是发起HEAD请求）

## 其他

- 调试模式，输出详细信息 `-v, --verbose`
- 自动跳转（跟踪302） `-L, --location`


## 参考资料
- [Linux系统入门学习：在curl中设置自定义的HTTP头_Linux教程_Linux公社-Linux系统门户网站](https://www.linuxidc.com/Linux/2015-02/114220.htm)
- [curl - How To Use](https://curl.haxx.se/docs/manpage.html)
- [How to POST JSON data with Curl from Terminal/Commandline to Test Spring REST? - Stack Overflow](https://stackoverflow.com/questions/7172784/how-to-post-json-data-with-curl-from-terminal-commandline-to-test-spring-rest)