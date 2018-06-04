---
title: JDK源码阅读-FileOutputStream
date: 2018-06-04 16:11:22
categories: [Java,JDK源码阅读]
tags: java
toc: true
---

`FileOutputStream`用户打开文件并获取输出流。

<!-- more -->

## 打开文件

```java
public FileOutputStream(File file, boolean append)
    throws FileNotFoundException
{
    String name = (file != null ? file.getPath() : null);
    SecurityManager security = System.getSecurityManager();
    if (security != null) {
        security.checkWrite(name);
    }
    if (name == null) {
        throw new NullPointerException();
    }
    if (file.isInvalid()) {
        throw new FileNotFoundException("Invalid file path");
    }
    this.fd = new FileDescriptor();
    fd.attach(this);
    this.append = append; // 记录是否是append追加模式
    this.path = name;

    open(name, append);
}

private void open(String name, boolean append)
    throws FileNotFoundException {
    open0(name, append);
}

private native void open0(String name, boolean append)
    throws FileNotFoundException;
```

```c
// jdk/src/solaris/native/java/io/FileOutputStream_md.c
JNIEXPORT void JNICALL
Java_java_io_FileOutputStream_open(JNIEnv *env, jobject this,
                                   jstring path, jboolean append) {
    // 使用O_WRONLY，O_CREAT模式打开文件，如果文件不存在会新建文件
    // 如果java中指定append参数为true，则使用O_APPEND追加模式
    // 如果java中指定append参数为false，则使用O_TRUNC模式，如果文件存在内容，会清空掉
    fileOpen(env, this, path, fos_fd,
             O_WRONLY | O_CREAT | (append ? O_APPEND : O_TRUNC));
}
```

`fileOpen`之后的流程与`FileInputStream`的一致，可以参考[JDK源码阅读-FileInputStream](http://imushan.com/2018/06/03/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileInputStream/)

## 写文件

`FileOutputStream`提供了三个write函数：

```java
public void write(int b) throws IOException {
    write(b, append);
}

public void write(byte b[]) throws IOException {
    writeBytes(b, 0, b.length, append);
}

public void write(byte b[], int off, int len) throws IOException {
    writeBytes(b, off, len, append);
}

private native void write(int b, boolean append) throws IOException;

private native void writeBytes(byte b[], int off, int len, boolean append)
    throws IOException;
```

```c
// jdk/src/solaris/native/java/io/FileOutputStream_md.c
JNIEXPORT void JNICALL
Java_java_io_FileOutputStream_write(JNIEnv *env, jobject this, jint byte, jboolean append) {
    writeSingle(env, this, byte, append, fos_fd);
}

JNIEXPORT void JNICALL
Java_java_io_FileOutputStream_writeBytes(JNIEnv *env,
    jobject this, jbyteArray bytes, jint off, jint len, jboolean append) {
    writeBytes(env, this, bytes, off, len, append, fos_fd);
}
```

```c
// jdk/src/share/native/java/io/io_util.c
void
writeSingle(JNIEnv *env, jobject this, jint byte, jboolean append, jfieldID fid) {
    // Discard the 24 high-order bits of byte. See OutputStream#write(int)
    char c = (char) byte;
    jint n;

    // 获取记录在FileDescriptor中的文件描述符
    FD fd = GET_FD(this, fid);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return;
    }
    // 追加模式和普通模式使用不同的函数
    if (append == JNI_TRUE) {
        n = IO_Append(fd, &c, 1);
    } else {
        n = IO_Write(fd, &c, 1);
    }
    if (n == -1) {
        JNU_ThrowIOExceptionWithLastError(env, "Write error");
    }
}

void
writeBytes(JNIEnv *env, jobject this, jbyteArray bytes,
           jint off, jint len, jboolean append, jfieldID fid)
{
    jint n;
    char stackBuf[BUF_SIZE];
    char *buf = NULL;
    FD fd;

    // 判断Java传入的byte数组是否是null
    if (IS_NULL(bytes)) {
        JNU_ThrowNullPointerException(env, NULL);
        return;
    }

    // 判断off和len参数是否数组越界
    if (outOfBounds(env, off, len, bytes)) {
        JNU_ThrowByName(env, "java/lang/IndexOutOfBoundsException", NULL);
        return;
    }

    // 如果写入长度为0，直接返回0
    if (len == 0) {
        return;
    } else if (len > BUF_SIZE) {
        // 如果写入长度大于BUF_SIZE（8192），无法使用栈空间buffer
        // 需要调用malloc在堆空间申请buffer
        buf = malloc(len);
        if (buf == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            return;
        }
    } else {
        buf = stackBuf;
    }

    // 复制Java传入的byte数组数据到C空间的buffer中
    (*env)->GetByteArrayRegion(env, bytes, off, len, (jbyte *)buf);

    if (!(*env)->ExceptionOccurred(env)) {
        off = 0;
        while (len > 0) {
            // 获取记录在FileDescriptor中的文件描述符
            fd = GET_FD(this, fid);
            if (fd == -1) {
                JNU_ThrowIOException(env, "Stream Closed");
                break;
            }

            // 追加模式和普通模式使用不同的函数
            if (append == JNI_TRUE) {
                n = IO_Append(fd, buf+off, len);
            } else {
                n = IO_Write(fd, buf+off, len);
            }
            if (n == -1) {
                JNU_ThrowIOExceptionWithLastError(env, "Write error");
                break;
            }
            off += n;
            len -= n;
        }
    }
    if (buf != stackBuf) {
        free(buf);
    }
}
```

`IO_Write`/`IO_Append`虽然看起来是两个不同的函数，其实是两个不同的宏定义，指向同一个函数`handleWrite`：

```c
// jdk/src/solaris/native/java/io/io_util_md.h
#define IO_Write handleWrite
#define IO_Append handleWrite
```

`handleWrite`中调用`write`系统调用写入数据：

```c
// jdk/src/solaris/native/java/io/io_util_md.c
ssize_t
handleWrite(FD fd, const void *buf, jint len)
{
    ssize_t result;
    RESTARTABLE(write(fd, buf, len), result);
    return result;
}
```

`FileOutputStream#write(byte[], int, int)`的主要流程：

1. 检查参数是否合法（byte数组不能为空，off和len没有越界）
2. 判断读取的长度，如果等于0直接返回0，如果大于BUF_SIZE需要在堆空间申请内存，如果`0<len<=BUF_SIZE`则直接在使用栈空间的缓存
3. 从Java空间的byte数组复制数据到中C空间的char数组中
4. 调用`write`系统调用写文件内容到系统中

**重要收获：**
1. 使用`FileOutputStream#write(byte[], int, int)`写入的长度，len一定不能大于8192！因为在小于8192时，会直接利用栈空间的char数组，如果大于，则需要调用malloc申请内存，并且还需要free释放内存，这是非常消耗时间的。
2. 相比于直接使用系统调用，Java的写入会多一次拷贝！

## 关闭文件

```java
public void close() throws IOException {
    synchronized (closeLock) {
        if (closed) {
            return;
        }
        closed = true;
    }

    if (channel != null) {
        channel.close();
    }

    fd.closeAll(new Closeable() {
        public void close() throws IOException {
            close0();
        }
    });
}
```

`FileOutputStream`关闭文件的逻辑和`FileInputStream`关闭文件的逻辑是一样的，参考[JDK源码阅读-FileDescriptor](http://imushan.com/2018/05/29/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileDescriptor/)

## 总结

- `FileOutputStream`打开文件使用`open`系统调用
- `FileOutputStream`写入文件使用`write`系统调用
- `FileOutputStream`关闭文件使用`close`系统调用
- 使用`FileOutputStream#write(byte[], int, int)`写入的长度，len一定不能大于8192！因为在小于8192时，会直接利用栈空间的char数组，如果大于，则需要调用malloc申请内存，并且还需要free释放内存，这是非常消耗时间的。
- 相比于直接使用系统调用，Java的写入会多一次拷贝！