---
title: Tomcat笔记-上传的请求体Tomcat是否会全部消费掉？
date: 2018-02-13 17:04:59
categories: [Tomcat]
tags: [tomcat,java]
toc: true
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

### 抓包分析

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

然后运行Wireshark进行抓包，这里需要注意，Windows下Wireshark默认无法抓取本机发给本机的请求，解决方法见[Wireshark笔记-抓取本机发给本机的请求](http://mushanshitiancai.github.io/2018/02/13/tools/Wireshark%E7%AC%94%E8%AE%B0-%E6%8A%93%E5%8F%96%E6%9C%AC%E6%9C%BA%E5%8F%91%E7%BB%99%E6%9C%AC%E6%9C%BA%E7%9A%84%E8%AF%B7%E6%B1%82/)。

断点先设置在UploadServlet#doPost上，看下业务逻辑请求之前，网络请求是如何的：

![](/img/tomcat/wireshark-before-servlet-1.png)

![](/img/tomcat/wireshark-before-servlet-2.png)

可以看出客户端会一直发送TCP报文，知道服务端的缓冲区满。然后客户端启动定时器判断是否可以继续发送剩下的数据。从上面的数据，还无法推论出Tomcat在让Servlet执行请求前是否读取了数据。

接着继续运行程序，看下Servlet逻辑执行后，会有什么网络请求：

![](/img/tomcat/wireshark-after-servlet-1.png)

![](/img/tomcat/wireshark-after-servlet-2.png)

![](/img/tomcat/wireshark-after-servlet-3.png)


可以看到在Servlet逻辑执行完毕后，服务端依然读取了全部的请求报文，然后才关闭连接的。为什么会有这种行为？Servlet执行完毕后，请求报文应该是没有意义了，再去读取，耗时耗力。还是得从源码层面来分析看看Tomcat在Servlet执行前后的具体行为。

### 源码分析

调试Tomcat的源码的方法可以参考：[Tomcat笔记-IDE中调试Tomcat源码 | 木杉的博客](http://mushanshitiancai.github.io/2018/02/13/java/tomcat/Tomcat%E7%AC%94%E8%AE%B0-IDE%E4%B8%AD%E8%B0%83%E8%AF%95Tomcat%E6%BA%90%E7%A0%81/)，我这里使用的Tomcat版本是`7.0.84`。

`org.apache.coyote.http11.AbstractHttp11Processor#process`这个函数是Tomcat处理请求的一个主循环：

```java
public SocketState process(SocketWrapper<S> socketWrapper)
    throws IOException {
    ...

    while (!getErrorState().isError() && keepAlive && !comet && !isAsync() &&
            upgradeInbound == null &&
            httpUpgradeHandler == null && !endpoint.isPaused()) {

        // 解析HTTP头部
        try {
            setRequestLineReadTimeout();
            ...
        } catch (IOException e) {
            ...
        }

        ...

        // 让Adapter处理请求，也就是让容器中的Servlet处理请求
        if (!getErrorState().isError()) {
            try {
                rp.setStage(org.apache.coyote.Constants.STAGE_SERVICE);
                adapter.service(request, response);
                
                ...
            } catch (Throwable t) {
               ...
            }
        }

        if (!isAsync() && !comet) {
            ...
            // 结束请求
            endRequest();
        }

        ...
}
```

可以看出Tomcat处理请求的主流程是：
1. 解析HTTP头部
2. 执行容器逻辑
3. 结束请求

结合抓包分析发现，在`setRequestLineReadTimeout()`和`endRequest()`这两个地方，服务端读取了TCP报文，接下来重点分析下此两处为何需要读取数据

org.apache.coyote.http11.Http11Processor#setRequestLineReadTimeout：

```java
@Override
protected void setRequestLineReadTimeout() throws IOException {
    
    if (inputBuffer.lastValid == 0 && socketWrapper.getLastAccess() > -1) {
        ...

        // 从socket读取数据到inputBuffer中
        if (!inputBuffer.fill()) {
            throw new EOFException(sm.getString("iib.eof.error"));
        }
        ...
    }
}
```

org.apache.coyote.http11.InternalInputBuffer#fill(boolean)：

```java
@Override
protected boolean fill(boolean block) throws IOException {
    int nRead = 0;

    if (parsingHeader) {
        // 如果已经读取的数据大小等于buf大小（并且外部逻辑还在尝试读取）
        // 说明请求的头部太大了，无法处理抛出异常
        if (lastValid == buf.length) {
            throw new IllegalArgumentException
                (sm.getString("iib.requestheadertoolarge.error"));
        }

        // 从socket的inputStream读取数据到buf中，读取的长度为buf.length - lastValid
        // lastValid为buf中已经读取数据偏移量，对于第一次读取头部时，为0
        nRead = inputStream.read(buf, pos, buf.length - lastValid);
        if (nRead > 0) {
            lastValid = pos + nRead;
        }

    } else {
        ...
    }
    return (nRead > 0);
}
```

从`fill()`的代码可以看出，请求到达Tomcat后，Tomcat为了处理HTTP的Header信息，会读取数据到buffer数组中，而所能处理的Header的最大长度，也就是这个数据的大小。我们可以跟一下看看这个数组是如何初始化的：

```java
public InternalInputBuffer(Request request, int headerBufferSize,
        boolean rejectIllegalHeaderName) {

    this.request = request;
    headers = request.getMimeHeaders();

    // 设置数组的容量为headerBufferSize
    buf = new byte[headerBufferSize];

    ...
}

// 默认值为8k
private int maxHttpHeaderSize = 8 * 1024;
public int getMaxHttpHeaderSize() { return maxHttpHeaderSize; }
public void setMaxHttpHeaderSize(int valueI) { maxHttpHeaderSize = valueI; }
```

最终可以看到在org.apache.coyote.http11.AbstractHttp11Protocol这个类中定义了maxHttpHeaderSize这个变量，默认值为8K，也就是说Tomcat默认支持的最长Header为8K，再大就会报错了。

同时我们可以从Tomcat的[配置文档](https://tomcat.apache.org/tomcat-7.0-doc/config/http.html)上看到这个配置项：

![](/img/tomcat/max-http-header-size.png)

上面分析了Tomcat在预处理请求时，会解析HTTP头部，所以这个时候会读取一次请求，最大会读取8K。那为啥在结束请求时，Tomcat还会去读取请求体呢？分析一下结束请求的流程：

org.apache.coyote.http11.AbstractHttp11Processor#endRequest

```java
public void endRequest() {

    // 结束请求
    if (getErrorState().isIoAllowed()) {
        try {
            getInputBuffer().endRequest();
        } catch (IOException e) {
            ...
        }
    }
    if (getErrorState().isIoAllowed()) {
        try {
            getOutputBuffer().endRequest();
        } catch (IOException e) {
            ...
        }
    }
}
```

org.apache.coyote.http11.AbstractInputBuffer#endRequest：

```java
/**
 * End request (consumes leftover bytes).
 */
public void endRequest() throws IOException {

    if (swallowInput && (lastActiveFilter != -1)) {
        int extraBytes = (int) activeFilters[lastActiveFilter].end();
        pos = pos - extraBytes;
    }
}
```

org.apache.coyote.http11.filters.IdentityInputFilter#end

```java
public long end() throws IOException {
    final boolean maxSwallowSizeExceeded = (maxSwallowSize > -1 && remaining > maxSwallowSize);
    long swallowed = 0;

    // 如果请求体剩余的没有读取的大小大于零，则Tomcat吃掉它
    while (remaining > 0) {

        int nread = buffer.doRead(endChunk, null);
        if (nread > 0 ) {
            swallowed += nread;
            remaining = remaining - nread;

            // 如果读取了太多了字节，则抛出异常
            if (maxSwallowSizeExceeded && swallowed > maxSwallowSize) {
                // Note: We do not fail early so the client has a chance to
                // read the response before the connection is closed. See:
                // http://httpd.apache.org/docs/2.0/misc/fin_wait_2.html#appendix
                throw new IOException(sm.getString("inputFilter.maxSwallow"));
            }
        } else { // errors are handled higher up.
            remaining = 0;
        }
    }

    // If too many bytes were read, return the amount.
    return -remaining;
}
```

从代码中可以看出，Tomcat在结束请求时，有一种Swallow机制，也就是把客户端发上来的，容器业务逻辑没有消费的请求体继续消费掉，或者称为吞掉。

可以从字节级别上验证：客户端上传的请求体大小为Content-Length表示的1048756字节：

![](/img/tomcat/remaining-1.png)

当我的Servlet没有任何读取request.inputStream的操作时，Tomcat结束请求的remaining的大小等于1048756，也就是完整的请求体大小：

![](/img/tomcat/remaining-2.png)

当我的Servlet程序读取全部的输入流时，Tomcat的结束请求流程中remaining=0，所以也就不会去执行swallow的流程了：

![](/img/tomcat/remaining-3.png)

同时通过代码看出，Tomcat也不是客户端发多少它就吞多少，而是有一个变量`maxSwallowSize`控制，如果Tomcat吞的字节大于这个变量，则会抛出IOException。

这个`maxSwallowSize`的初始值也定义在`org.apache.coyote.http11.AbstractHttp11Protocol`中：

```java
// 默认值是2M
private int maxSwallowSize = 2 * 1024 * 1024;
public int getMaxSwallowSize() { return maxSwallowSize; }
public void setMaxSwallowSize(int maxSwallowSize) {
    this.maxSwallowSize = maxSwallowSize;
}
```

`maxSwallowSize `的默认值是2M，所以如果请求体大于2M，Tomcat不会继续消费，而是抛出异常并关闭连接。Tomcat官网上关于这个配置项的描述：

![](/img/tomcat/max-swallow-size.png)

看到这个配置还是非常激动的，因为这个和实验时发现上传2M文件会失败的同事的现象吻合了。我试着上传大于2M的文件，的确浏览器提示连接被中断：

![](/img/tomcat/chrome-err-connection-aborted.png)

当然，这种情况会发生是因为业务逻辑没有消费掉这个上传的文件，如果业务逻辑正常消费掉这个文件，是不会发生这种异常的。

知道了Tomcat的这个逻辑，现在的问题是，为何Tomcat要去消费掉业务逻辑都不管的请求体呢？对于上传文件这种请求体很大的场景，这一步可能消费掉不少资源和时间。

目前的推论是：虽然TCP是全双工的，也就是在服务端没有读取客户端发来的消息时，也依然可以给客户端发送响应，但是如果没有接收完客户端发来的消息就关闭连接，客户端是会报错的（连接被中断），所以Tomcat为了保证客户端不报错所以尝试读取剩余的请求体，但是出于资源考虑，限制了最大读取的字节数默认为2M。对于大部分非文件上传请求，这个大小也足够了。

同时注意下上面贴出的代码中有这么一段注释：

```
// Note: We do not fail early so the client has a chance to
// read the response before the connection is closed. See:
// http://httpd.apache.org/docs/2.0/misc/fin_wait_2.html#appendix
```

主要是一段Roy Fielding的关于为什么HTTP需要拖延关闭（lingering）功能，Roy Fielding是HTTP/1.1的作者之一：

```
Below is a message from Roy Fielding, one of the authors of HTTP/1.1.

Why the lingering close functionality is necessary with HTTP
The need for a server to linger on a socket after a close is noted a couple times in the HTTP specs, but not explained. This explanation is based on discussions between myself, Henrik Frystyk, Robert S. Thau, Dave Raggett, and John C. Mallery in the hallways of MIT while I was at W3C.

If a server closes the input side of the connection while the client is sending data (or is planning to send data), then the server's TCP stack will signal an RST (reset) back to the client. Upon receipt of the RST, the client will flush its own incoming TCP buffer back to the un-ACKed packet indicated by the RST packet argument. If the server has sent a message, usually an error response, to the client just before the close, and the client receives the RST packet before its application code has read the error message from its incoming TCP buffer and before the server has received the ACK sent by the client upon receipt of that buffer, then the RST will flush the error message before the client application has a chance to see it. The result is that the client is left thinking that the connection failed for no apparent reason.

There are two conditions under which this is likely to occur:

sending POST or PUT data without proper authorization
sending multiple requests before each response (pipelining) and one of the middle requests resulting in an error or other break-the-connection result.
The solution in all cases is to send the response, close only the write half of the connection (what shutdown is supposed to do), and continue reading on the socket until it is either closed by the client (signifying it has finally read the response) or a timeout occurs. That is what the kernel is supposed to do if SO_LINGER is set. Unfortunately, SO_LINGER has no effect on some systems; on some other systems, it does not have its own timeout and thus the TCP memory segments just pile-up until the next reboot (planned or not).

Please note that simply removing the linger code will not solve the problem -- it only moves it to a different and much harder one to detect.
```

这段说明的大致意思是：

```
如果服务端要关闭一个正在发送或者正打算发送数据的客户端连接，TCP栈会发出一个RST（Reset）包给客户端，客户端一旦收到RST包，则会根据RST包中的信息重置其接收缓冲区的报文为un-ACKed。如果服务端发送了响应数据给客户端，但是在客户端代码读取这个响应信息前收到了RST报文，那么这个RST报文会在客户端代码读取这个响应信息前刷掉这个服务端发来的响应信息，导致客户端代码再也无法读取到这个响应。结果就是客户端认为连接不明不白的失败了。

解决方法就是服务端发送了响应后，只关闭连接的写部分（shutdown就是这个功能），然后继续读取客户端发来的数据，直到它也被客户端关闭了，或者是连接超时了。内核的SO_LINGER标志位就是这个效果，但是不幸的是不是所有系统都有效。
```

RST包的说明可以参考：[简单说说TCP(5) --- RST](http://blog.csdn.net/eric0318/article/details/51113018)，这篇文章提到的出现RST包的场景，就包含上面描述的场景：

```
4. 当recv buffer还有数据时应用程序关闭连接 
A、B建立连接后，A发送5000字节的数据给B，但是B只读了4096字节，之后就调用closesocket()，此时，B会向A发送一个RST包。
```

## 总结

1. TCP的流量控制可以保障发送方的报文不会淹没接收方，当接收方的接收窗口大小为0时，发送方就不会继续发送了
2. Tomcat在调用Servlet处理请求前，会处理HTTP请求中的头部信息，会读取数据，最多会读取`maxHttpHeaderSize`（默认8k）长度的内容
3. Tomcat在调用Servlet处理请求后，会判断是否有剩余的未消费的请求体数据，如果有则消费掉，最多消费`maxSwallowSize`（默认2M）长度的数据，如果用户发送的请求体大于`maxSwallowSize`，则强行关闭连接。

## 参考资料
- [TCP的流量控制和拥塞控制 - CSDN博客](http://blog.csdn.net/yechaodechuntian/article/details/25429143)
- [TCP协议的滑动窗口具体是怎样控制流量的？ - 知乎](https://www.zhihu.com/question/32255109)
- [TCP的接收缓冲区满了，收到数据后会向发送方发送ACK吗？该怎么解决 - CSDN博客](http://blog.csdn.net/witsmakemen/article/details/27319951)
- [Apache Tomcat 7 Configuration Reference (7.0.84) - The HTTP Connector](https://tomcat.apache.org/tomcat-7.0-doc/config/http.html)