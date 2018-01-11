---
title: FFmpeg笔记-Stream specifiers
date: 2018-01-10 20:22:50
categories:
tags: [ffmpeg]
---

ffmpeg的一些选项是可以作用到具体的stream上的，比如编解码器，是可以指定具体的哪个流用哪种编解码器的。所以需要一种方式能指定具体的流，也就是Stream specifiers。

<!--more-->

Stream specifiers追加在选项后面，两者通过冒号隔开。比如：`-codec:a:1 ac3`，指的是对于第二个音频流，使用ac3编解码器。

Stream specifiers还可以同时指定多个流，比如：`-b:a 128k`就选中了所有的音频流。

如果不指定Stream specifiers，则选项会应用到素有流上，比如：`-codec copy`和`-codec: copy`。

Stream specifiers可以有一下几种格式：

- `stream_index`

  流的索引，从0开始。比如：`-threads:1 4`设置第二个流用的线程数为4

- `stream_type[:stream_index]`

  stream_type为流的类型，可选值有：

  1. `v`和`V`匹配视频（`v`匹配所有视频流，`V`只匹配视频流而不匹配衍生的附加图片，视频缩略图，封面等）
  2. `a`匹配音频
  3. `s`匹配字幕
  4. `d`匹配data
  5. `t`匹配附件

  如果指定了`[:stream_index]`则匹配对应的类型的第几个流，否则匹配这个类型的所有流。

- `p:program_id[:stream_index]`

通过`program_id`指定对应的程序。（不是很明白）

- `#stream_id`或者`i:stream_id`

通过流的`stream_id`直接匹配流（有些格式支持这种特性）

- `m:key[:value]`

匹配元数据包含有`key`的流，如果指定了`[:value]`，则还要求值要匹配。

- `u`

通过配置匹配流（可能有些编解码器支持，不是很明白）

## 参考资料
- [ffmpeg Documentation](http://ffmpeg.org/ffmpeg-all.html#Stream-specifiers)