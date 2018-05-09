---
title: AWS S3 Range下载响应测试
date: 2018-05-09 09:44:02
categories:
tags: [http]
---

HTTP范围请求（Range Requests）是用于获取对象指定范围内容的请求规范，常用语HTTP断点续传和多线程下载。

Range头部的格式可能的格式较多，这里通过调用AWS S3服务来看一下，一个规范的文件下载服务是如何响应范围请求的。

HTTP范围请求的资料可以参考：

- [RFC7233 HTTP范围请求(Range Requests)](https://blog.csdn.net/u012062760/article/details/77096479)
- [RFC 7233 - Hypertext Transfer Protocol (HTTP/1.1): Range Requests](https://tools.ietf.org/html/rfc7233)

<!-- more -->

请求范例：

```
请求：
#GET http://s3-ap-southeast-1.amazonaws.com/cs-aws-prod/1e9471c2-a37a-46ef-8ff2-24668784a6b4
HTTP Request (com.jcabi.http.request.BaseRequest):
Authorization: AWS AKIAIMS5FEA5TVKVCJSQ:YOEn+UYjvog0N95eyoutbDuqypQ=
Date: Wed, 09 May 2018 01:42:31 GMT
Range: bytes=1-10

[request body length = 0]

响应：
206 Partial Content [http://s3-ap-southeast-1.amazonaws.com/cs-aws-prod/1e9471c2-a37a-46ef-8ff2-24668784a6b4]
Accept-Ranges: bytes
ETag: "3535ffff5715f4e218758b22dce07bfb"
X-Amz-Request-Id: BCEDD052EF0DDF74
Content-Length: 10
X-Amz-Id-2: ru/QjNwx4QfHz2Jn+pO8kdrj4mDO7YM4NiTigA1EOJcR4lIaV8XpjJw79tbVyPKKpCgum9htdYM=
Content-Range: bytes 1-10/53
Date: Wed, 09 May 2018 01:42:34 GMT
Last-Modified: Wed, 09 May 2018 01:42:30 GMT
Server: AmazonS3
Content-Type: binary/octet-stream

[body length = 10]
```

测试结果：

| Range头部                  |  格式合法  |响应码       | 响应体                     |  Content-Range                 |
|----------------------------|----------|------------|----------------------------|--------------------------------|
| Range:                     | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: a                   | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: 0                   | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes               | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes a             | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes 1             | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=1             | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=-             | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=1-10-         | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=1-10a         | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=1--           | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=1--1          | 不合法    |   200      |  返回全部内容               | 无                             |
| Range: bytes=10-1          | **不合法**|   200      |  返回全部内容               | 无                             |
| Range: bytes=0-            | 合法      | **206**    |  返回全部内容               | bytes 0-${len-1}/${len}        |
| Range: bytes=1-            | 合法      | **206**    |  返回第一个字节到最后一个字节 | bytes 1-${len-1}/${len}        |
| Range: bytes={len}-        | 合法      | **416**    |  InvalidRange错误信息       | 无                              |
| Range: bytes=-10           | 合法      | **206**    |  返回最后10个字节           | bytes ${len-10}-${len-1}/${len} |
| Range: bytes=-{len}        | 合法      | **206**    |  返回全部内容               | bytes 0-${len-1}/${len}        |
| Range: bytes=-{len+1}      | 合法      | **206**    |  返回全部内容               | bytes 0-${len-1}/${len}        |
| Range: bytes=1-10          | 合法      | **206**    |  返回第一个字节到第10个字节  | bytes 1-10/${len}               |
| Range: bytes=0-{len+1}     | 合法      | **206**    |  返回全部内容               |bytes 0-${len-1}/${len}           |
| Range: bytes={len-1}-{len} | 合法      | **206**    |  返回最后一个字节            |bytes ${len - 1}-${len - 1}/${len} |
| Range: bytes={len}-{len+1} | 合法      | **416**    | InvalidRange错误信息       |  无                                 |
| Range: bytes=1-2,3-4       | 合法      | **200**    | 返回全部内容(说明S3不支持多段范围请求)  | 无                        |


总结：
1. 不合法的Range头部都被忽略（而不是抛出异常）
2. 合法的Range请求，都响应206（即使返回的内容是文件完整的内容）
3. 如果Range的起点位置大于文件最后一个字节，则响应416
4. 如果Range的终点位置大于文件最后一个字节，不会抛出异常，而是范围到最后一个字节为止
5. 在响应416的情况下，S3不会响应头部Content-Range: bytes */47022（RFC中是建议（SHOULD而不是MUST，参考[资料](https://tools.ietf.org/html/rfc7233#section-4.4)）响应这个头部，以便于客户端知道文件的大小调整请求）
6. AWS S3不支持多段范围请求