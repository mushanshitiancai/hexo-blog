---
title: 'FFmpeg笔记--vcodec和-c:v,-acodec和-c:a的区别？'
date: 2018-01-10 16:50:33
categories:
tags: [ffmpeg]
---

在看ffmpeg命令的时候经常会看到有些地方使用`--vcodec`指定视频解码器，而有些地方使用`-c:v`指定视频解码器，那这两个有没有区别呢？

<!--more-->

ffmpeg的官方文档：

```
-vcodec codec (output)
  Set the video codec. This is an alias for -codec:v.
```

也就是说`-vcodec`和`-codec:v`等价。但是并没有说和`-c:v`等价啊。看一下`-codec:v`的文档：

```
-c[:stream_specifier] codec (input/output,per-stream)
-codec[:stream_specifier] codec (input/output,per-stream)
    Select an encoder (when used before an output file) or a decoder (when used before an input file) for one or more streams. codec is the name of a decoder/encoder or a special value copy (output only) to indicate that the stream is not to be re-encoded.

    For example

        ffmpeg -i INPUT -map 0 -c:v libx264 -c:a copy OUTPUT

        encodes all video streams with libx264 and copies all audio streams.

    For each stream, the last matching c option is applied, so

        ffmpeg -i INPUT -map 0 -c copy -c:v:1 libx264 -c:a:137 libvorbis OUTPUT

        will copy all the streams except the second video, which will be encoded with libx264, and the 138th audio, which will be encoded with libvorbis.
```

也就是说`-codec`和`-c`是等价的。所以`--vcodec`和`-c:v`是等价的。

文档说明-codec可以为指定的流设置编码器，具体通过`stream_specifier`来指定。

## -ab和-b参数去哪里了？

在看资料的时候发现有些文字中用到了`-ab`和`-b`参数，但是官网文档没有这两个参数。。

后来通过`ffmpeg- h`发现了这两个参数：

```
-ab bitrate         audio bitrate (please use -b:a)
-b bitrate          video bitrate (please use -b:v)
```

可以看出这两个参数分别设定音频比特率和视频比特率，但是已经不推荐使用这种写法了，改为使用`-b:a`和`-b:v`。

## 参考资料
- [ffmpeg - Difference between -c:v and -vcodec, and -c:a and -acodec? - Super User](https://superuser.com/questions/835048/difference-between-cv-and-vcodec-and-ca-and-acodec)