---
title: HttpClient学习笔记
date: 2017-02-07 16:22:18
categories: [Java]
tags: [java]
toc: true
---

HttpClient是Java界中被广泛使用的HTTP协议的客户端编程工具包。使用HttpClient我们可以像浏览器一样发送请求和接收响应。

<!--more-->

## 简单使用
在pom文件中添加依赖：

```xml
<dependency>
  <groupId>org.apache.httpcomponents</groupId>
  <artifactId>httpclient</artifactId>
  <version>4.5.3</version>
</dependency>
```

get请求例子：

```java
CloseableHttpClient httpclient = HttpClients.createDefault();
HttpGet httpGet = new HttpGet("http://targethost/homepage");
CloseableHttpResponse response = httpclient.execute(httpGet);

// 注意1：底层HTTP连接还被response对象持有。这是为了可以直接使用这个链接socket来传输返回数据。
// 所以在使用完毕后，**一定**要记得调用CloseableHttpResponse#close()方法。
// 注意2：response的content必须要被完整的消费（InputStream被正确的close），否则可能无法被安全地重用。
try {
    System.out.println(response.getStatusLine());
    HttpEntity entity = response.getEntity();
    // 使用响应中的内容
    // 要确保entity中的输入流被正确关闭
    EntityUtils.consume(entity);
} finally {
    response.close();
}
```

`EntityUtils.consume(entity)`相当于如下代码：

```java
if (entity != null) {
    InputStream instream = entity.getContent();
    try {
        // do something useful
    } finally {
        instream.close();
    }
}
```

或者使用Java7的Try-With-Resource：

```java
CloseableHttpClient httpclient = HttpClients.createDefault();
HttpGet httpGet = new HttpGet("http://baidu.com");

try (CloseableHttpResponse response = httpclient.execute(httpGet)){
    System.out.println(response.getStatusLine());
    HttpEntity entity = response.getEntity();
    // 使用响应中的内容
    // 要确保entity中的输入流被正确关闭
    EntityUtils.consume(entity);
} 
```

post的例子：

```java
CloseableHttpClient httpclient = HttpClients.createDefault();
HttpPost httpPost = new HttpPost("http://targethost/login");
List<NameValuePair> nvps = new ArrayList<NameValuePair>();
nvps.add(new BasicNameValuePair("username", "vip"));
nvps.add(new BasicNameValuePair("password", "secret"));
httpPost.setEntity(new UrlEncodedFormEntity(nvps));
CloseableHttpResponse response = httpclient.execute(httpPost);

try {
    System.out.println(response.getStatusLine());
    HttpEntity entity = response.getEntity();
    // 使用响应中的内容
    // 要确保entity中的输入流被正确关闭
    EntityUtils.consume(entity);
} finally {
    response.close();
}
```

## 构建URI
发送GET请求是很简单的：

```java
HttpGet httpget = new HttpGet("http://www.google.com/search?hl=en&q=httpclient&btnG=Google+Search&aq=f&oq=");
```

但是直接拼接请求URI不太方便，HttpClient提供了`URIBuilder`工具类来做这个任务：

```java
URI uri = new URIBuilder()
    .setScheme("http")
    .setHost("www.google.com")
    .setPath("/search")
    .setParameter("q", "httpclient")
    .setParameter("btnG", "Google Search")
    .setParameter("aq", "f")
    .setParameter("oq", "")
    .build();
HttpGet httpget = new HttpGet(uri);

System.out.println(httpget.getURI());
// http://www.google.com/search?q=httpclient&btnG=Google+Search&aq=f&oq=
```

如果只是想拼接参数部分，可以使用`URLEncodedUtils`这个工具类：

```java
List<NameValuePair> formparams = new ArrayList<NameValuePair>();
formparams.add(new BasicNameValuePair("param1", "value 1"));
formparams.add(new BasicNameValuePair("param2", "value2"));
String format = URLEncodedUtils.format(formparams, HTTP.DEF_CONTENT_CHARSET); // 默认编码是ISO_8859_1

System.out.println(format);
// param1=value+1&param2=value2
```

前文中提到POST的例子中，使用到了`UrlEncodedFormEntity`来生成POST的请求体，这个类依赖的就是`URLEncodedUtils`类。

## Response handlers（响应处理器）
在处理结果时，我们不但要记得关闭response，还需要记得关闭response中entity的流。这种形式上的要求总是不安全的，一旦我们在编码中忘记了这两个步骤，就会导致连接没有被良好地复用等问题。所以在处理结果时，推荐使用`ResponseHandler`。

ResponseHandler接口只有一个方法：

```java
public interface ResponseHandler<T> {
    T handleResponse(HttpResponse response) throws ClientProtocolException, IOException;
}
```

我们实现ResponseHandler接口，在`handleResponse`函数中处理response，返回处理后的结果。例子如下：

```java
CloseableHttpClient httpClient = HttpClients.createDefault();
HttpGet httpGet = new HttpGet("http://baidu.com");

String result = httpClient.execute(httpGet, response -> {
    // 使用response...
    return "result";
});
```

是不是比前面提到的代码简单很多。如果传入ResponseHandler参数，`execute`在执行请求时，无论我们在处理结果时成功还是失败，都会帮我们关闭entity的输入流，和response持有的底层连接。

> 注意：HttpClient 4.3.6的ResponseHandler处理有BUG，请使用最新的HttpClient 4.5.3。具体分析见下文。


## 发现：HttpClient 4.3.6中CloseableHttpClient#execute的BUG
我在阅读HttpClient源码的过程中发现，4.3.6的带requestHandler参数的execute函数有BUG：

```java
public <T> T execute(final HttpHost target, final HttpRequest request,
        final ResponseHandler<? extends T> responseHandler, final HttpContext context)
        throws IOException, ClientProtocolException {
    Args.notNull(responseHandler, "Response handler");

    final HttpResponse response = execute(target, request, context);

    final T result;
    try {
        result = responseHandler.handleResponse(response);
    } catch (final Exception t) {
        final HttpEntity entity = response.getEntity();
        try {
            EntityUtils.consume(entity);
        } catch (final Exception t2) {
            // Log this exception. The original exception is more
            // important and will be thrown to the caller.
            this.log.warn("Error consuming content after an exception.", t2);
        }
        if (t instanceof RuntimeException) {
            throw (RuntimeException) t;
        }
        if (t instanceof IOException) {
            throw (IOException) t;
        }
        throw new UndeclaredThrowableException(t);
    }

    // Handling the response was successful. Ensure that the content has
    // been fully consumed.
    final HttpEntity entity = response.getEntity();
    EntityUtils.consume(entity);
    return result;
}
```

注意代码中没有对response调用close，而且外部也无法访问这个response，这就导致底层连接没有释放了。

而最新的4.5.3中已经修复了这个问题：

```java
public <T> T execute(final HttpHost target, final HttpRequest request,
        final ResponseHandler<? extends T> responseHandler, final HttpContext context)
        throws IOException, ClientProtocolException {
    Args.notNull(responseHandler, "Response handler");

    final CloseableHttpResponse response = execute(target, request, context);
    try {
        final T result = responseHandler.handleResponse(response);
        final HttpEntity entity = response.getEntity();
        EntityUtils.consume(entity);
        return result;
    } catch (final ClientProtocolException t) {
        // Try to salvage the underlying connection in case of a protocol exception
        final HttpEntity entity = response.getEntity();
        try {
            EntityUtils.consume(entity);
        } catch (final Exception t2) {
            // Log this exception. The original exception is more
            // important and will be thrown to the caller.
            this.log.warn("Error consuming content after an exception.", t2);
        }
        throw t;
    } finally {
        response.close(); // ⭐️ 这里正确的关闭了连接
    }
}
```


## 参考资料
- [Apache HttpComponents – HttpClient Quick Start](http://hc.apache.org/httpcomponents-client-ga/quickstart.html)
- [Httpclient核心架构设计-博客-云栖社区-阿里云](https://yq.aliyun.com/articles/57408)