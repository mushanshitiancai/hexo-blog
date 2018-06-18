---
title: Java如何保证文件落盘？
date: 2018-06-18 21:20:49
categories: [Java]
tags: java
toc: true
---

在之前的文章我们聊了从应用到操作系统，我们要如何保证文件落盘，来确保掉电等故障不会导致数据丢失。JDK也封装了对应的功能，并且为我们做好了跨平台的保证。

<!-- more -->

JDK中有三种方式可以强制文件数据落盘：

1. 调用`FileDescriptor#sync`函数
2. 调用`FileChannel#force`函数
3. 使用`RandomAccessFile`以`rws`或者`rwd`模式打开文件

## `FileDescriptor#sync`

`FileDescriptor`类提供了`sync`方法，可以用于保证数据保存到持久化存储设备后返回：

```java
FileOutputStream outputStream = new FileOutputStream("/Users/mazhibin/b.txt");
outputStream.getFD().sync();
```

可以看一下JDK是如何实现`FileDescriptor#sync`的：

```java
public native void sync() throws SyncFailedException;
```

```c
// jdk/src/solaris/native/java/io/FileDescriptor_md.c
JNIEXPORT void JNICALL
Java_java_io_FileDescriptor_sync(JNIEnv *env, jobject this) {
    // 获取文件描述符
    FD fd = THIS_FD(this);
    // 调用IO_Sync来执行数据同步
    if (IO_Sync(fd) == -1) {
        JNU_ThrowByName(env, "java/io/SyncFailedException", "sync failed");
    }
}
```

`IO_Sync`在UNIX系统上的定义就是`fsync`：

```c
// jdk/src/solaris/native/java/io/io_util_md.h
#define IO_Sync fsync
```

## `FileChannel#force`

之前的文章提到了，操作系统提供了`fsync`/`fdatasync`两个用户同步数据到持久化设备的系统调用，后者尽可能的会不同步文件元数据，来减少一次磁盘IO，提高性能。但是Java IO的`FileDescriptor#sync`只是对fsync的封装，JDK中没有对于`fdatasync`的封装，这是一个特性缺失。

Java NIO对这一点也做了增强，`FileChannel`类的`force`方法，支持传入一个布尔参数`metaData`，表示是否需要确保文件元数据落盘，如果为`true`，则调用`fsync`。如果为`false`，则调用`fdatasync`。

使用范例：

```java
FileOutputStream outputStream = new FileOutputStream("/Users/mazhibin/b.txt");

// 强制文件数据与元数据落盘
outputStream.getChannel().force(true);

// 强制文件数据落盘，不关系元数据是否落盘
outputStream.getChannel().force(false);
```

我们来看看其实现：

```java
public class FileChannelImpl extends FileChannel {
    private final FileDispatcher nd;
    private final FileDescriptor fd;
    private final NativeThreadSet threads = new NativeThreadSet(2);

    public final boolean isOpen() {
        return open;
    }

    private void ensureOpen() throws IOException {
        if(!this.isOpen()) {
            throw new ClosedChannelException();
        }
    }

    // 布尔参数metaData用于指定是否需要文件元数据也确保落盘
    public void force(boolean metaData) throws IOException {
        // 确保文件是已经打开的
        ensureOpen();
        int rv = -1;
        int ti = -1;
        try {
            begin();
            ti = threads.add();

            // 再次确保文件是已经打开的
            if (!isOpen())
                return;
            do {
                // 调用FileDispatcher#force
                rv = nd.force(fd, metaData);
            } while ((rv == IOStatus.INTERRUPTED) && isOpen());
        } finally {
            threads.remove(ti);
            end(rv > -1);
            assert IOStatus.check(rv);
        }
    }
}
```

实现中有许多线程同步相关的代码，不属于我们要关注的部分，就不分析了。`FileChannel#force`调用`FileDispatcher#force`。

`FileDispatcher`是NIO内部实现用的一个类，封装了一些文件操作方法，其中包含了刷新文件的方法：

```java
abstract class FileDispatcher extends NativeDispatcher {

    abstract int force(FileDescriptor fd, boolean metaData) throws IOException;

    // ...
}
```

`FileDispatcher#force`的实现：

```java
class FileDispatcherImpl extends FileDispatcher
{

    int force(FileDescriptor fd, boolean metaData) throws IOException {
        return force0(fd, metaData);
    }

    static native int force0(FileDescriptor fd, boolean metaData) throws IOException;

    // ...
}
```

`FileDispatcher#force`的本地方法实现：

```c
JNIEXPORT jint JNICALL
Java_sun_nio_ch_FileDispatcherImpl_force0(JNIEnv *env, jobject this,
                                          jobject fdo, jboolean md)
{
    // 获取文件描述符
    jint fd = fdval(env, fdo);
    int result = 0;

    if (md == JNI_FALSE) {
        // 如果调用者认为不需要同步文件元数据，调用fdatasync
        result = fdatasync(fd);
    } else {
#ifdef _AIX
        /* On AIX, calling fsync on a file descriptor that is opened only for
         * reading results in an error ("EBADF: The FileDescriptor parameter is
         * not a valid file descriptor open for writing.").
         * However, at this point it is not possibly anymore to read the
         * 'writable' attribute of the corresponding file channel so we have to
         * use 'fcntl'.
         */
        int getfl = fcntl(fd, F_GETFL);
        if (getfl >= 0 && (getfl & O_ACCMODE) == O_RDONLY) {
            return 0;
        }
#endif
        // 如果调用者认为需要同步文件元数据，调用fsync
        result = fsync(fd);
    }
    return handle(env, result, "Force failed");
}
```

可以看出，其实就是简单的通过`metaData`参数来区分调用`fsync`和`fdatasync`。

## RandomAccessFile结合rws/rwd模式

`RandomAccessFile`打开文件支持4中模式：

- "r"	以只读方式打开。调用结果对象的任何 write 方法都将导致抛出 IOException。
- "rw"	打开以便读取和写入。如果该文件尚不存在，则尝试创建该文件。
- "rws"	打开以便读取和写入，对于 "rw"，还要求对文件的内容或元数据的每个更新都同步写入到底层存储设备。
- "rwd" 打开以便读取和写入，对于 "rw"，还要求对文件内容的每个更新都同步写入到底层存储设备。

其中`rws`模式会在`open`文件时传入`O_SYNC`标志位。`rwd`模式会在`open`文件时传入`O_DSYNC`标志位。

具体的源码分析参考：[JDK源码阅读-RandomAccessFile](http://imushan.com/2018/06/04/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-RandomAccessFile/)

## 参考资料
- [PhD's Research](http://yongkunphd.blogspot.com/2013/12/how-fsync-works-in-java.html)
- [storage - Really force file sync/flush in Java - Stack Overflow](https://stackoverflow.com/questions/730521/really-force-file-sync-flush-in-java)