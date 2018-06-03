---
title: JDK源码阅读-FileInputStream
date: 2018-06-03 09:45:24
categories: [Java,JDK源码阅读]
tags: java
toc: true
---

`FileIntputStream`用于打开一个文件并获取输入流。

<!-- more -->

## 打开文件

我们来看看`FileIntputStream`打开文件时，做了什么操作：

```java
public FileInputStream(File file) throws FileNotFoundException {
    String name = (file != null ? file.getPath() : null);
    SecurityManager security = System.getSecurityManager();
    if (security != null) {
        security.checkRead(name);
    }
    if (name == null) {
        throw new NullPointerException();
    }
    if (file.isInvalid()) {
        throw new FileNotFoundException("Invalid file path");
    }
    fd = new FileDescriptor();
    fd.attach(this);
    path = name;
    open(name);
}

private void open(String name) throws FileNotFoundException {
    open0(name);
}

private native void open0(String name) throws FileNotFoundException;
```

`FileIntputStream`的构造函数，在Java层面做的事情不多：

1. 检查是否有读取文件的权限
2. 判断文件路径是否合法
3. 新建`FileDescriptor`实例
4. 调用`open0`本地方法

`FileDescriptor`类对应操作系统的文件描述符，具体可以参考[JDK源码阅读-FileDescriptor](http://imushan.com/2018/05/29/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileDescriptor/)这篇文章。

```cpp
// jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT void JNICALL
Java_java_io_FileInputStream_open0(JNIEnv *env, jobject this, jstring path) {
    fileOpen(env, this, path, fis_fd, O_RDONLY);
}

// jdk/src/solaris/native/java/io/io_util_md.c
void
fileOpen(JNIEnv *env, jobject this, jstring path, jfieldID fid, int flags)
{
    WITH_PLATFORM_STRING(env, path, ps) {
        FD fd;

#if defined(__linux__) || defined(_ALLBSD_SOURCE)
        // 如果是Linux或BSD，去掉path结尾的/，因为这些内核不需要
        char *p = (char *)ps + strlen(ps) - 1;
        while ((p > ps) && (*p == '/'))
            *p-- = '\0';
#endif
        fd = JVM_Open(ps, flags, 0666); // 打开文件拿到文件描述符
        if (fd >= 0) {
            SET_FD(this, fd, fid); // 非负整数认为是正确的文件描述符，设置到fd字段
        } else {
            throwFileNotFoundException(env, path);  // 负数认为是不正确文件描述符，抛出FileNotFoundException异常
        }
    } END_PLATFORM_STRING(env, ps);
}
```

`FileOutputStream#open`的JNI代码逻辑也比较简单：

1. 如果是Linux或BSD，去掉path结尾的/，因为这些内核不需要
2. 调用`JVM_Open`函数打开文件，得到文件描述符
3. 调用`SET_FD`设置文件描述符到`FileDescriptor#fd`

`SET_FD`用于设置文件描述符到`FileDescriptor#fd`，具体可以参考[JDK源码阅读-FileDescriptor](http://imushan.com/2018/05/29/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileDescriptor/)这篇文章。

`JVM_Open`根据其命名可以看得出来是JVM提供的函数，可以看出JDK的实现是分为多层的：Java-JNI-JDK，需要和操作系统交互的代码在JNI层面，一些每个操作系统都需要提供的真正底层的方法JVM来提供。具体的这个分层设计以后如果能有机会看JVM实现应该能有更深的理解。

`JVM_Open`的实现可以在Hotspot虚拟机的代码中找到：

```cpp
// hotspot/src/share/vm/prims/jvm.cpp
JVM_LEAF(jint, JVM_Open(const char *fname, jint flags, jint mode))
  JVMWrapper2("JVM_Open (%s)", fname);

  //%note jvm_r6
  int result = os::open(fname, flags, mode);  // 调用os::open打开文件
  if (result >= 0) {
    return result;
  } else {
    switch(errno) {
      case EEXIST:
        return JVM_EEXIST;
      default:
        return -1;
    }
  }
JVM_END

// hotspot/src/os/linux/vm/os_linux.cpp
int os::open(const char *path, int oflag, int mode) {

  // 如果path长度大于MAX_PATH，抛出异常
  if (strlen(path) > MAX_PATH - 1) {
    errno = ENAMETOOLONG;
    return -1;
  }
  int fd;
  // O_DELETE是JVM自定义的一个flag，要在传递给操作系统前去掉
  int o_delete = (oflag & O_DELETE);
  oflag = oflag & ~O_DELETE;

  // 调用open64打开文件
  fd = ::open64(path, oflag, mode);
  if (fd == -1) return -1;

  // 问打开成功也可能是目录，这里还需要判断是否打开的是普通文件
  {
    struct stat64 buf64;
    int ret = ::fstat64(fd, &buf64);
    int st_mode = buf64.st_mode;

    if (ret != -1) {
      if ((st_mode & S_IFMT) == S_IFDIR) {
        errno = EISDIR;
        ::close(fd);
        return -1;
      }
    } else {
      ::close(fd);
      return -1;
    }
  }

#ifdef FD_CLOEXEC
    // 设置文件描述符标志FD_CLOEXEC
    // 这样在fork和exec时，子进程就不会收到父进程打开的文件描述符的影响
    // 具体参考[FD_CLOEXEC用法及原因_转](https://www.cnblogs.com/embedded-linux/p/6753617.html)
    {
        int flags = ::fcntl(fd, F_GETFD);
        if (flags != -1)
            ::fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
    }
#endif

  if (o_delete != 0) {
    ::unlink(path);
  }
  return fd;
}
```

可以看到JVM最后使用`open64`这个方法打开文件，网上对于`open64`这个资料还是很少的，我找到的是[man page for open64 (all section 2) - Unix & Linux Commands](https://www.unix.com/man-page/All/2/open64/)，从中可以看出，`open64`是为了在32位环境打开大文件的系统调用，但是不是标准的一部分。和`open`+`O_LARGEFILE`效果是一样的。参考：[c - Wrapper for open() and open64() and see that system calls by vi uses open64() - Stack Overflow](https://stackoverflow.com/questions/5245306/wrapper-for-open-and-open64-and-see-that-system-calls-by-vi-uses-open64)

这样完整的打开文件流程就分析完了，去掉各种函数调用，本质上只做了两件事：

1. 调用`open`系统调用打开文件
2. 保存得到的文件描述符到`FileDescriptor#fd`中

## 读取文件

```java
public int read() throws IOException {
    return read0();
}

private native int read0() throws IOException;

public int read(byte b[]) throws IOException {
    return readBytes(b, 0, b.length);
}

public int read(byte b[], int off, int len) throws IOException {
    return readBytes(b, off, len);
}

private native int readBytes(byte b[], int off, int len) throws IOException;
```

可以看出，`FileInputStream`的三个主要read方法，依赖于两个本地方法，先来看看读取一个字节的`read0`方法：

```java
// jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT jint JNICALL
Java_java_io_FileInputStream_read0(JNIEnv *env, jobject this) {
    return readSingle(env, this, fis_fd);
}

// jdk/src/share/native/java/io/io_util.c
jint
readSingle(JNIEnv *env, jobject this, jfieldID fid) {
    jint nread;
    char ret;

    // 获取记录在FileDescriptor中的文件描述符
    FD fd = GET_FD(this, fid);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return -1;
    }

    // 调用IO_Read读取一个字节
    nread = IO_Read(fd, &ret, 1);
    if (nread == 0) { /* EOF */
        return -1;
    } else if (nread == -1) { /* error */
        JNU_ThrowIOExceptionWithLastError(env, "Read error");
    }
    return ret & 0xFF;
}

// jdk/src/solaris/native/java/io/io_util_md.h
#define IO_Read handleRead

// jdk/src/solaris/native/java/io/io_util_md.c
ssize_t
handleRead(FD fd, void *buf, jint len)
{
    ssize_t result;
    // 调用read系统调用读取文件
    RESTARTABLE(read(fd, buf, len), result);
    return result;
}

// jdk/src/solaris/native/java/io/io_util_md.h
/*
 * Retry the operation if it is interrupted
 * 如果被中断，则重试的宏
 */
#define RESTARTABLE(_cmd, _result) do { \
    do { \
        _result = _cmd; \
    } while((_result == -1) && (errno == EINTR)); \
} while(0)
```

read的过程并没有使用JVM提供的函数，而是直接使用open系统调用，为什么有这个区别，目前不太清楚。

```java
// jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT jint JNICALL
Java_java_io_FileInputStream_readBytes(JNIEnv *env, jobject this,
        jbyteArray bytes, jint off, jint len) {
    return readBytes(env, this, bytes, off, len, fis_fd);
}

// jdk/src/share/native/java/io/io_util.c
/* 
 * The maximum size of a stack-allocated buffer.
 * 栈上能分配的最大buffer大小
 */
#define BUF_SIZE 8192

jint
readBytes(JNIEnv *env, jobject this, jbyteArray bytes,
          jint off, jint len, jfieldID fid)
{
    jint nread;
    char stackBuf[BUF_SIZE]; // BUF_SIZE=8192
    char *buf = NULL;
    FD fd;

    // 传入的Java byte数组不能是null
    if (IS_NULL(bytes)) {
        JNU_ThrowNullPointerException(env, NULL);
        return -1;
    }
    // off，len参数是否越界判断
    if (outOfBounds(env, off, len, bytes)) {
        JNU_ThrowByName(env, "java/lang/IndexOutOfBoundsException", NULL);
        return -1;
    }

    // 如果要读取的长度是0，直接返回读取长度0
    if (len == 0) {
        return 0;
    } else if (len > BUF_SIZE) {
        // 如果要读取的长度大于BUF_SIZE，则不能在栈上分配空间了，需要在堆上分配空间
        buf = malloc(len);
        if (buf == NULL) {
            // malloc分配失败，抛出OOM异常
            JNU_ThrowOutOfMemoryError(env, NULL);
            return 0;
        }
    } else {
        buf = stackBuf;
    }

    // 获取记录在FileDescriptor中的文件描述符
    fd = GET_FD(this, fid);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        nread = -1;
    } else {
        // 调用IO_Read读取
        nread = IO_Read(fd, buf, len);
        if (nread > 0) {
            // 读取成功后，从buf拷贝数据到Java的byte数组中
            (*env)->SetByteArrayRegion(env, bytes, off, nread, (jbyte *)buf);
        } else if (nread == -1) {
            // read系统调用返回-1是读取失败
            JNU_ThrowIOExceptionWithLastError(env, "Read error");
        } else { /* EOF */
            // 操作系统read读取返回0认为是读取结束，Java中返回-1认为是读取结束
            nread = -1;
        }
    }

    // 如果使用的是堆空间（len > BUF_SIZE），需要手动释放
    if (buf != stackBuf) {
        free(buf);
    }
    return nread;
}
```

`FileInputStream#read(byte[], int, int)`的主要流程：

1. 检查参数是否合法（byte数组不能为空，off和len没有越界）
2. 判断读取的长度，如果等于0直接返回0，如果大于BUF_SIZE需要在堆空间申请内存，如果`0<len<=BUF_SIZE`则直接在使用栈空间的缓存
3. 调用`read`系统调用读取文件内容到内存中
4. 从C空间的char数组复制数据到Java空间的byte数组中

**重要收获：**
1. 使用`FileInputStream#read(byte[], int, int)`读取的长度，len一定不能大于8192！因为在小于8192时，会直接利用栈空间的char数组，如果大于，则需要调用malloc申请内存，并且还需要free释放内存，这是非常消耗时间的。
2. 相比于直接使用系统调用，Java的读取会多一次拷贝！（思考：使用C标准库的fread和Java的read，复制次数是一样，还是fread会少一次？）

## 移动偏移量

```java
public native long skip(long n) throws IOException;
```

```c
// jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT jlong JNICALL
Java_java_io_FileInputStream_skip(JNIEnv *env, jobject this, jlong toSkip) {
    jlong cur = jlong_zero;
    jlong end = jlong_zero;

    // 获取记录在FileDescriptor中的文件描述符
    FD fd = GET_FD(this, fis_fd);
    if (fd == -1) {
        JNU_ThrowIOException (env, "Stream Closed");
        return 0;
    }

    // 调用seek系统调用移动当前偏移量
    if ((cur = IO_Lseek(fd, (jlong)0, (jint)SEEK_CUR)) == -1) {
        // 获取当前文件偏移量
        JNU_ThrowIOExceptionWithLastError(env, "Seek error");
    } else if ((end = IO_Lseek(fd, toSkip, (jint)SEEK_CUR)) == -1) {
        // 移动偏移量
        JNU_ThrowIOExceptionWithLastError(env, "Seek error");
    }
    return (end - cur);
}

// jdk/src/solaris/native/java/io/io_util_md.h
#ifdef _ALLBSD_SOURCE
#define open64 open
#define fstat64 fstat
#define stat64 stat
#define lseek64 lseek
#define ftruncate64 ftruncate
#define IO_Lseek lseek
#else
#define IO_Lseek lseek64
#endif
```

## 获取文件可读取的字节数

```java
public native int available() throws IOException;
```

```c
// jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT jint JNICALL
Java_java_io_FileInputStream_available(JNIEnv *env, jobject this) {
    jlong ret;
    // 获取记录在FileDescriptor中的文件描述符
    FD fd = GET_FD(this, fis_fd);
    if (fd == -1) {
        JNU_ThrowIOException (env, "Stream Closed");
        return 0;
    }
    // 调用IO_Available获取可读字节数
    if (IO_Available(fd, &ret)) {
        if (ret > INT_MAX) {
            ret = (jlong) INT_MAX;
        } else if (ret < 0) {
            ret = 0;
        }
        return jlong_to_jint(ret);
    }
    JNU_ThrowIOExceptionWithLastError(env, NULL);
    return 0;
}

// jdk/src/solaris/native/java/io/io_util_md.h
#define IO_Available handleAvailable

// jdk/src/solaris/native/java/io/io_util_md.c
jint
handleAvailable(FD fd, jlong *pbytes)
{
    int mode;
    struct stat64 buf64;
    jlong size = -1, current = -1;

    // 获取文件的长度
    int result;
    RESTARTABLE(fstat64(fd, &buf64), result);
    if (result != -1) {
        mode = buf64.st_mode;
        if (S_ISCHR(mode) || S_ISFIFO(mode) || S_ISSOCK(mode)) {
            // 字符特殊文件，管道或FIFO，套接字
            int n;
            int result;
            RESTARTABLE(ioctl(fd, FIONREAD, &n), result);
            if (result >= 0) {
                *pbytes = n;
                return 1;
            }
        } else if (S_ISREG(mode)) {
            // 普通文件，从st_size字段可以直接获取文件大小
            size = buf64.st_size;
        }
    }

    // 获取当前文件偏移量
    if ((current = lseek64(fd, 0, SEEK_CUR)) == -1) {
        return 0;
    }

    // 如果fstat获取的大小小于当前偏移量，则通过偏移量方式再次获取文件长度
    if (size < current) {
        if ((size = lseek64(fd, 0, SEEK_END)) == -1)
            return 0;
        else if (lseek64(fd, current, SEEK_SET) == -1)
            return 0;
    }

    // 文件长度减去当前偏移量得到文件可读长度
    *pbytes = size - current;
    return 1;
}
```

## 关闭文件

```
public void close() throws IOException {
    // 保证只有一个线程会执行关闭逻辑
    synchronized (closeLock) {
        if (closed) {
            return;
        }
        closed = true;
    }
    // 关闭关联的Channel
    if (channel != null) {
        channel.close();
    }

    // 调用FileDescriptor的closeAll，关闭所有相关流，并调用close系统调用关闭文件描述符
    fd.closeAll(new Closeable() {
        public void close() throws IOException {
            close0();
        }
    });
}
```

关闭文件的流程可以参考[JDK源码阅读-FileDescriptor](http://imushan.com/2018/05/29/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileDescriptor/)

## 总结

- `FileInputStream`打开文件使用`open`系统调用
- `FileInputStream`读取文件使用`read`系统调用
- `FileInputStream`关闭文件使用`close`系统调用
- `FileInputStream`修改文件当前偏移量使用`lseek`系统调用
- `FileInputStream`获取文件可读字节数使用`fstat`系统调用
- 使用`FileInputStream#read(byte[], int, int)`读取的长度，len一定不能大于8192！因为在小于8192时，会直接利用栈空间的char数组，如果大于，则需要调用malloc申请内存，并且还需要free释放内存，这是非常消耗时间的。
- 相比于直接使用系统调用，Java的读取文件会多一次拷贝！因为使用read读取文件内容到C空间的数组后，需要拷贝数据到JVM的堆空间的数组中

## 参考资料
- [JDK源码阅读-FileDescriptor](http://imushan.com/2018/05/29/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileDescriptor/)
- [FD_CLOEXEC用法及原因_转](https://www.cnblogs.com/embedded-linux/p/6753617.html)
- [man page for open64 (all section 2) - Unix & Linux Commands](https://www.unix.com/man-page/All/2/open64/)
- [c - Wrapper for open() and open64() and see that system calls by vi uses open64() - Stack Overflow](https://stackoverflow.com/questions/5245306/wrapper-for-open-and-open64-and-see-that-system-calls-by-vi-uses-open64)