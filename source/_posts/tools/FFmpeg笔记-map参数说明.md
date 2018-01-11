---
title: FFmpeg笔记-map参数说明
date: 2018-01-10 20:20:17
categories:
tags: [ffmpeg]
---

ffmpeg的map参数可以指定输入流和输出流的映射关系。

<!--more-->

参数格式：

```
-map [-]input_file_id[:stream_specifier][?][,sync_file_id[:stream_specifier]] | [linklabel] (output)
```

`input_file_id`指定输入文件索引，从0开始，比如0表示第一个输入文件，1表示第二个输入文件。

`stream_specifier`指定对应的文件中具体的流。可以参考：[FFmpeg笔记-Stream specifiers | 木杉的博客](http://mushanshitiancai.github.io/2018/01/10/tools/FFmpeg%E7%AC%94%E8%AE%B0-Stream-specifiers/)

`input_file_id`前面的负号表示从已经建立的map关系中去掉这个映射。

`?`问号表示如果对应的流不存在则忽略。否则默认是会报错提示这个流不存在的。

具体使用得看例子：

映射第一个输入的所有流到输出：

    ffmpeg -i INPUT -map 0 output

假设输入文件中有两个音频流，他们可以通过0:0和0:1指定，然后下面的命令选择第二个音频到输出文件（第一个流忽略）：

    ffmpeg -i INPUT -map 0:1 out.wav

选择a.mov的第三个流和b.mov的第七个流输出到out.mov中：

    ffmpeg -i a.mov -i b.mov -c copy -map 0:2 -map 1:6 out.mov

选择所有的视频流，和第三个音频流到输出文件：

    ffmpeg -i INPUT -map 0:v -map 0:a:2 OUTPUT

从输入中剔除第一个音频流：

    ffmpeg -i INPUT -map 0 -map -0:a:1 OUTPUT

选择第一个输入文件的视频和音频流到输出，如果不存在音频流，不报错：

    ffmpeg -i INPUT -map 0:v -map 0:a? OUTPUT

选择英语流到输出：

    ffmpeg -i INPUT -map 0:m:language:eng OUTPUT

## 参考资料
- [ffmpeg Documentation](http://ffmpeg.org/ffmpeg.html#Advanced-options)