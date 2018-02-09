---
title: FFmpeg笔记-静态编译FFmpeg
date: 2018-02-01 17:18:11
categories:
tags: [ffmpeg]
---

目标机器是内核版本2.63.2的，但是ffmpeg官网提供的静态编译是基于3.2.0的，所以需要自己编译。

<!--more-->

以下步骤参考：[CompilationGuide/Centos – FFmpeg](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)，只在少数步骤有一点调整。原文没有编译libtheora，这里添加上了。

编译机器：

```
$ cat /etc/issue
CentOS release 6.9 (Final)

$ uname -a
Linux ip-172024-133091.test.nd 2.6.32-696.10.1.el6.x86_64 #1 SMP Tue Aug 22 18:51:35 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```

安装编译工具：

```
yum install autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
```

新建源码目录：

```
mkdir ~/ffmpeg_sources
```

安装NASM：

```
cd ~/ffmpeg_sources
curl -O -L http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2
tar xjvf nasm-2.13.02.tar.bz2
cd nasm-2.13.02
./autogen.sh
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
```

安装Yasm：

```
cd ~/ffmpeg_sources
curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
```

安装libx264转码器：

```
cd ~/ffmpeg_sources
git clone --depth 1 http://git.videolan.org/git/x264
cd x264
git checkout stable
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
```

如果不切换分支到stable分支，make提示错误：

```
filters/video/resize.c: In function ‘pick_closest_supported_csp’:
filters/video/resize.c:215: error: ‘AVComponentDescriptor’ has no member named ‘depth’
```

安装libx265编码器：

```
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
```

安装aac编码器：

```
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
```

安装libmp3lame编码器：

```
cd ~/ffmpeg_sources
curl -O -L http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install
```

安装libopus编码器：

```
cd ~/ffmpeg_sources
curl -O -L https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz
tar xzvf opus-1.2.1.tar.gz
cd opus-1.2.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
```

安装libogg编码器：

```
cd ~/ffmpeg_sources
curl -O -L http://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz
tar xzvf libogg-1.3.3.tar.gz
cd libogg-1.3.3
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
```

安装libvorbis编码器：

```
cd ~/ffmpeg_sources
curl -O -L http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
tar xzvf libvorbis-1.3.5.tar.gz
cd libvorbis-1.3.5
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install
```

安装libtheora编码器：

```
cd ~/ffmpeg_sources
curl -O -L http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf 	libtheora-1.1.1.tar.gz
cd 	libtheora-1.1.1
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install
```


安装libvpx编码器：

```
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make
make install
```

这里遇到一个问题，就是google这个网址无法访问，找到有翻墙能力的浏览器，访问https://chromium.googlesource.com/webm/libvpx.git/+/v1.7.0，下载源码并上传到服务器

```
mkdir libvpx
tar xzvf libvpx.git-f80be22a1099b2a431c2796f529bb261064ec6b4.tar.gz -C libvpx
```

然后继续执行命令。

安装ffmpeg：

```
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
make
make install
hash -r
```

在~/bin目录下有静态编译好的ffmpeg和ffprobe。

我把命令文件复制到其他机器上执行，提示错误：

```
./ffmpeg: error while loading shared libraries: libfreetype.so.6: cannot open shared object file: No such file or directory`
```

是因为freetype的依赖没有，安装即可：

```
yum install -y  freetype-devel 
```

## 参考资料
- [CompilationGuide/Generic – FFmpeg](https://trac.ffmpeg.org/wiki/CompilationGuide/Generic)
- [CompilationGuide/Centos – FFmpeg](https://trac.ffmpeg.org/wiki/CompilationGuide/Centos)
- [libtheora-1.1.1](http://www.linuxfromscratch.org/blfs/view/cvs/multimedia/libtheora.html)