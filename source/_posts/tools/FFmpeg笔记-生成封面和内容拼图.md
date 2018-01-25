---
title: FFmpeg笔记-生成封面和内容拼图
date: 2018-01-25 11:09:34
categories:
tags: [ffmpeg]
---

封面和内容拼图（也不知道官方的该怎么称呼这种图片，我这里就先称为内容拼图了）可以让我们对视频有大致的了解，在视频分享网站上很常见。今天说说怎么用FFmpeg+Java生成封面和内容拼图。

<!--more-->

## 封面

FFmpeg截取封面非常简单，一个命令可以搞定：

```
ffmpeg -i input.flv -ss 00:00:14.435 -vframes 1 out.png
```

参数解释：
- `-ss`：时间字符串，指定截取时间点。如果指定的时间大于视频的最大时间，则没有输出。
- `-vframes 1`：指定输出多少帧，这里就输出一帧

时间字符串的格式为`[HH:]MM:SS[.m...]`或者`S+[.m...]`。比如：55，12:03:45，23.189

## 内容拼图

QQ影音的剧情连拍功能就是内容拼图，可以指定图片的宽度和布局，然后按一定时间截取视频：

![](/img/ffmpeg/qqplayer-thumbnail-menu.png)

![](/img/ffmpeg/qqplayer-thumbnail-setting.png)

![](/img/ffmpeg/qqplayer-thumbnail.png)

FFmpeg没法一个命令搞定内容拼图，我采用的方法是先让FFmpeg按固定时间截取图片保存到一个目录下，然后再用一段Java程序吧这些图片拼接起来。

相关命令：

```
# 获取视频的时长，用于计算每秒截取几帧
ffprobe -v quiet -show_format -print_format json "inputFilePath"

# 按指定的fps截取视频，输出到指定位置下，输出文件名格式为：out001.png,out002.png...
ffmpeg -i "inputFilePath" -vf fps=1 out%3d.png
```

Java代码如下：

```java
/**
    * 拼接多张图片文件到一张图片中
    *
    * @param files     用于拼图的图片文件列表
    * @param width     输出拼图的宽度
    * @param height    输出拼图的高度
    * @param row       拼图的行数
    * @param column    拼图的列数
    * @param pageCount 指定输出几张拼图。如果小于等于0或者大于最大输出的张数，则为最大输出的张数
    */
public List<BufferedImage> mergeImageFiles(List<File> files, int width, int height, int row, int column, int pageCount) throws IOException {
    if (width <= 0 || height <= 0) {
        throw new IllegalArgumentException("wight/height is zero or negative");
    }
    if (column <= 0 || row <= 0) {
        throw new IllegalArgumentException("column/row is zero or negative");
    }
    if (files == null) {
        throw new IllegalArgumentException("image files is null or empty");
    }
    if (files.isEmpty()) {
        return Lists.newArrayList(new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB));
    }

    List<BufferedImage> imageItemList = new ArrayList<>();
    for (File file : files) {
        BufferedImage image = ImageIO.read(file);
        imageItemList.add(image);
    }

    return mergeImages(imageItemList, width, height, row, column, pageCount);
}

public List<BufferedImage> mergeImages(List<BufferedImage> images, int width, int height, int row, int column, int pageCount) throws IOException {
    if (width <= 0 || height <= 0) {
        throw new IllegalArgumentException("wight/height is zero or negative");
    }
    if (column <= 0 || row <= 0) {
        throw new IllegalArgumentException("column/row is zero or negative");
    }
    if (images == null) {
        throw new IllegalArgumentException("image files is null or empty");
    }
    if (images.isEmpty()) {
        return Lists.newArrayList(new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB));
    }

    int pageImageCount = column * row;
    int fullPageCount = (int) Math.ceil(images.size() / (double) pageImageCount);
    if (pageCount <= 0 || pageCount > fullPageCount) {
        pageCount = fullPageCount;
    }
    List<BufferedImage> pageList = new ArrayList<>(pageCount);

    int partWidth = width / column;
    int partHeight = height / row;

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
        BufferedImage resultImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = resultImage.createGraphics();

        for (int rowIndex = 0; rowIndex < row; rowIndex++) {
            for (int columnIndex = 0; columnIndex < column; columnIndex++) {
                int fileIndex = (pageIndex * pageImageCount) + (rowIndex * column) + columnIndex;
                if (fileIndex >= images.size()) break;

                BufferedImage partImage = images.get(fileIndex);

                int currentPartWidth = partWidth;
                int currentPartHeight = partHeight;
                int currentDeltaX = 0;
                int currentDeltaY = 0;
                double widthScale = partImage.getWidth() / (double) partWidth;
                double heightScale = partImage.getHeight() / (double) partHeight;
                if (widthScale > heightScale) {
                    currentPartHeight = (int) (partImage.getHeight() / widthScale);
                    currentDeltaY = (partHeight - currentPartHeight) / 2;
                } else {
                    currentPartWidth = (int) (partImage.getWidth() / heightScale);
                    currentDeltaX = (partWidth - currentPartWidth) / 2;
                }

                int currentX = columnIndex * partWidth + currentDeltaX;
                int currentY = rowIndex * partHeight + currentDeltaY;
                graphics.drawImage(partImage,
                        currentX, currentY, currentX + currentPartWidth, currentY + currentPartHeight,
                        0, 0, partImage.getWidth(), partImage.getHeight(),
                        null);
            }
        }

        pageList.add(resultImage);
    }

    return pageList;
}
```

效果：

![](/img/ffmpeg/java-marge-result.png)
