---
title: Tomcat笔记-上传的请求体Tomcat是否会全部消费掉？
date: 2018-02-13 17:04:59
categories: [Tomcat]
tags: [tomcat,java]
---

同事提了这样一个问题：上传一个100M文件，但是请求逻辑并没有消费这个文件，那这个文件会上传到服务器上么？

<!-- more -->

第一个反应是不会，因为这种情况下这个文件还上传上来的话，是很笨的做法，明明不需要这个请求体的数据，为什么还要读取到服务器上。不过同事的实验结果是，越大的文件调用这个没有任何处理逻辑的接口，速度越慢，也就是说因为服务器接收了完整的文件，所以才会有这个现象。

而另外一个同事在实验时，发现了更诡异的问题，上传0-2M的文件可以成功，但是上传大于2M的文件，会提示错误，信息为连接中断了。

## TCP层面

首先这个问题从底层来看的话，有一个前置问题，即客户端向服务端发送请求时，服务端会一直接收报文到内存中吗？会导致占满服务端资源而无法响应码？会导致占满内存后丢失后续报文的数据吗？

首先不是TCP接收报文不是接收到内存中，而是接收到缓冲区中。

然后TCP的流量控制用于控制发送端发送数据的速率，以便接收端来得及接收。

TCP在ACK报文中会携带窗口大小，说明接收端缓存的的剩余空间大小，发送端发送的数据不会大于这个窗口大小，所以如果接收方来不及消费数据，则接下来的ACK报文中窗口大小会逐渐减小，以限制发送端发送速率。如果接收端缓冲区满了，ACK报文中的窗口大小为0，则发送方不会再发送数据。那发送端怎么知道何时该继续发送呢？方法是启动一个计时器，计时器时间到后发送一个1字节的零窗口检测报文，直到返回的窗口不再为零然后继续发送数据。

所以回到用户通过HTTP协议上传大文件的问题，在TCP这一层，缓冲区会满了后，客户端就不会继续发送了，直到服务端程序读取了数据后，才会继续发送。

## Tomcat层面

TCP层面，通过流量控制，用户发送的文件不会无限制的发送到服务器上。那在Tomcat层面，Tomcat会把请求体完全读取到内存中吗？

这个分两个阶段考虑，一个是在业务逻辑执行前，Tomcat是否会把请求读取到内存中，一个是业务逻辑执行后，Tomcat是否还会继续消费掉业务逻辑没有消费的请求体？

写一个简单的上传程序，然后通过抓包来分析看下网络请求是如何的。

```jsp
<html>
<head>
    <title>Upload</title>
</head>
<body>
<form action="/upload" method="post" enctype="multipart/form-data">
    <label for="file">请选择文件: </label><input id="file" type="file" name="file">
    <input type="submit">
</form>
</body>
</html>
```

```java
public class UploadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("UploadServlet begin service");
        System.out.println("UploadServlet finish service");
    }
}
```










## 参考资料
- [TCP的流量控制和拥塞控制 - CSDN博客](http://blog.csdn.net/yechaodechuntian/article/details/25429143)
- [TCP协议的滑动窗口具体是怎样控制流量的？ - 知乎](https://www.zhihu.com/question/32255109)
- [TCP的接收缓冲区满了，收到数据后会向发送方发送ACK吗？该怎么解决 - CSDN博客](http://blog.csdn.net/witsmakemen/article/details/27319951)