---
title: JDK源码阅读-RandomAccessFile
date: 2018-06-04 21:27:48
categories: [Java,JDK源码阅读]
tags: java
toc: true
---

`FileInputStream`只能用于读取文件，`FileOutputStream`只能用于写入文件，而对于同时读取文件，并且需要随意移动文件当前偏移量的话，就需要使用`RandomAccessFile`这个类了。`RandomAccessFile`是对操作系统提供的文件读写能力最完整的封装。

<!-- more -->

## 打开文件

RAF打开文件时，除了指定文件对象，还需要指定一个模式，取值有：

- "r"	以只读方式打开。调用结果对象的任何 write 方法都将导致抛出 IOException。
- "rw"	打开以便读取和写入。如果该文件尚不存在，则尝试创建该文件。
- "rws"	打开以便读取和写入，对于 "rw"，还要求对文件的内容或元数据的每个更新都同步写入到底层存储设备。
- "rwd" 打开以便读取和写入，对于 "rw"，还要求对文件内容的每个更新都同步写入到底层存储设备。

"rws"和"rwd"的效率比"rw"低非常非常多，因为每次读写都需要刷到磁盘才会返回，这两个中"rwd"比"rws"效率高一些，因为"rwd"只刷新文件内容，"rws"刷新文件内容与元数据，文件的元数据就是文件更新时间等信息。

这些特性是操作系统提供的特性，通过这次阅读源码，我们来看看是如何使用这些特性来实现上面的这些模式的。

```java
// 4个标志位，用于组合表示4种模式
private static final int O_RDONLY = 1;
private static final int O_RDWR =   2;
private static final int O_SYNC =   4;
private static final int O_DSYNC =  8;

public RandomAccessFile(File file, String mode)
    throws FileNotFoundException
{
    String name = (file != null ? file.getPath() : null);
    int imode = -1;
    // 只读模式
    if (mode.equals("r"))
        imode = O_RDONLY;
    else if (mode.startsWith("rw")) {
        // 读写模式
        imode = O_RDWR;
        rw = true;

        // 读写模式下，可以结合O_SYNC和O_DSYNC标志
        if (mode.length() > 2) {
            if (mode.equals("rws"))
                imode |= O_SYNC;
            else if (mode.equals("rwd"))
                imode |= O_DSYNC;
            else
                imode = -1;
        }
    }
    if (imode < 0)
        throw new IllegalArgumentException("Illegal mode \"" + mode
                                            + "\" must be one of "
                                            + "\"r\", \"rw\", \"rws\","
                                            + " or \"rwd\"");
    SecurityManager security = System.getSecurityManager();
    if (security != null) {
        security.checkRead(name);
        if (rw) {
            security.checkWrite(name);
        }
    }
    if (name == null) {
        throw new NullPointerException();
    }
    if (file.isInvalid()) {
        throw new FileNotFoundException("Invalid file path");
    }
    // 新建文件描述符
    fd = new FileDescriptor();
    fd.attach(this);
    path = name;
    open(name, imode);
}

private void open(String name, int mode)
    throws FileNotFoundException {
    open0(name, mode);
}

private native void open0(String name, int mode)
    throws FileNotFoundException;
```

```c
// jdk/src/share/native/java/io/RandomAccessFile.c
JNIEXPORT void JNICALL
Java_java_io_RandomAccessFile_open0(JNIEnv *env,
                                    jobject this, jstring path, jint mode)
{
    int flags = 0;
    // JAVA中的标志位与操作系统标志位转换
    if (mode & java_io_RandomAccessFile_O_RDONLY)
        flags = O_RDONLY;
    else if (mode & java_io_RandomAccessFile_O_RDWR) {
        flags = O_RDWR | O_CREAT;
        if (mode & java_io_RandomAccessFile_O_SYNC)
            flags |= O_SYNC;
        else if (mode & java_io_RandomAccessFile_O_DSYNC)
            flags |= O_DSYNC;
    }

    // 调用fileOpen打开函数
    fileOpen(env, this, path, raf_fd, flags);
}
```

`fileOpen`之后的流程与`FileInputStream`的一致，可以参考[JDK源码阅读-FileInputStream](http://imushan.com/2018/06/03/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileInputStream/)

可以看出，相比于`FileInputStream`固定使用`O_RDONLY`，`FileOutputStream`固定使用`O_WRONLY | O_CREAT`，`RandomAccessFile`提供了在Java中指定打开模式的能力。

## 读取文件

```java
public int read() throws IOException {
    return read0();
}

public int read(byte b[]) throws IOException {
    return readBytes(b, 0, b.length);
}

public int read(byte b[], int off, int len) throws IOException {
    return readBytes(b, off, len);
}
```

这三个读取函数的实现与`FileInputStream`一致，可以参考[JDK源码阅读-FileInputStream](http://imushan.com/2018/06/03/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileInputStream/)

`RandomAccessFile`还提供了一个遍历方法，用于读取指定长度的数据，如果还没读取到指定长度就到文件尾，抛出`EOFException`：

```java
public final void readFully(byte b[]) throws IOException {
    readFully(b, 0, b.length);
}

public final void readFully(byte b[], int off, int len) throws IOException {
    int n = 0;
    do {
        int count = this.read(b, off + n, len - n);
        if (count < 0)
            throw new EOFException();
        n += count;
    } while (n < len);
}
```

## 文件偏移量相关操作

### 获取当前文件偏移量

```java
public native long getFilePointer() throws IOException;
```

```c
// jdk/src/share/native/java/io/RandomAccessFile.c
JNIEXPORT jlong JNICALL
Java_java_io_RandomAccessFile_getFilePointer(JNIEnv *env, jobject this) {
    FD fd;
    jlong ret;

    // 获取记录在FileDescriptor中的文件描述符
    fd = GET_FD(this, raf_fd);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return -1;
    }
    // 通过seek当前偏移量0个字节的方式获取当前文件偏移量
    if ((ret = IO_Lseek(fd, 0L, SEEK_CUR)) == -1) {
        JNU_ThrowIOExceptionWithLastError(env, "Seek failed");
    }
    return ret;
}
```

### 设置当前文件偏移量

```java
public void seek(long pos) throws IOException {
    if (pos < 0) {
        throw new IOException("Negative seek offset");
    } else {
        seek0(pos);
    }
}

private native void seek0(long pos) throws IOException;
```

```c
// jdk/src/share/native/java/io/RandomAccessFile.c
JNIEXPORT void JNICALL
Java_java_io_RandomAccessFile_seek0(JNIEnv *env,
                    jobject this, jlong pos) {

    FD fd;

    // 获取记录在FileDescriptor中的文件描述符
    fd = GET_FD(this, raf_fd);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return;
    }
    
    if (pos < jlong_zero) {
        JNU_ThrowIOException(env, "Negative seek offset");
    } else if (IO_Lseek(fd, pos, SEEK_SET) == -1) {
        // 设置文件偏移量为pos指定的位置，SEEK_SET表示表示移动到的位置距离文件开始处pos长度
        JNU_ThrowIOExceptionWithLastError(env, "Seek failed");
    }
}
```

`RandomAccessFile`还提供了相对当前位置移动文件偏移量的方法：

```java
// jdk/src/share/native/java/io/RandomAccessFile.c
public int skipBytes(int n) throws IOException {
    long pos;
    long len;
    long newpos;

    if (n <= 0) {
        return 0;
    }
    // 当前文件当前偏移量
    pos = getFilePointer();
    // 获取文件长度
    len = length();
    newpos = pos + n;

    // 如果文件偏移量大于文件尾，则设置为文件尾（Java自己做的限制）
    if (newpos > len) {
        newpos = len;
    }
    seek(newpos);

    /* return the actual number of bytes skipped */
    return (int) (newpos - pos);
}

这个方法不是原子的，所以多线程操作的时候要注意。

### 获取文件长度

```java
public native long length() throws IOException;
```

```c
// jdk/src/share/native/java/io/RandomAccessFile.c
JNIEXPORT jlong JNICALL
Java_java_io_RandomAccessFile_length(JNIEnv *env, jobject this) {
    FD fd;
    jlong cur = jlong_zero;
    jlong end = jlong_zero;

    // 获取记录在FileDescriptor中的文件描述符
    fd = GET_FD(this, raf_fd);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return -1;
    }

    if ((cur = IO_Lseek(fd, 0L, SEEK_CUR)) == -1) {
        JNU_ThrowIOExceptionWithLastError(env, "Seek failed");
    } else if ((end = IO_Lseek(fd, 0L, SEEK_END)) == -1) {
        JNU_ThrowIOExceptionWithLastError(env, "Seek failed");
    } else if (IO_Lseek(fd, cur, SEEK_SET) == -1) {
        JNU_ThrowIOExceptionWithLastError(env, "Seek failed");
    }
    return end;
}
```

获取文件长度的流程：
1. 获取当前文件偏移量，记录下来
2. 设置当前文件偏移量到文件未，得到文件的长度
3. 设置当前文件偏移量到之前记录的位置
4. 返回文件长度

这么来看，UNIX系统上精确获取文件长度的做法就只这个流程了。

### 设置文件长度

```java
public native void setLength(long newLength) throws IOException;
```

```c
// jdk/src/share/native/java/io/RandomAccessFile.c
JNIEXPORT void JNICALL
Java_java_io_RandomAccessFile_setLength(JNIEnv *env, jobject this,
                                        jlong newLength)
{
    FD fd;
    jlong cur;

    // 获取记录在FileDescriptor中的文件描述符
    fd = GET_FD(this, raf_fd);
    if (fd == -1) {
        JNU_ThrowIOException(env, "Stream Closed");
        return;
    }
    // 获取当前文件偏移量
    if ((cur = IO_Lseek(fd, 0L, SEEK_CUR)) == -1) goto fail;

    // 调用ftruncate来设置文件长度
    if (IO_SetLength(fd, newLength) == -1) goto fail;

    // 设置文件长度后，恢复文件偏移量
    // 如果是缩小了文件，并且文件偏移量大于现在的文件长度，设置文件偏移量为文件尾
    if (cur > newLength) {
        if (IO_Lseek(fd, 0L, SEEK_END) == -1) goto fail;
    } else {
        if (IO_Lseek(fd, cur, SEEK_SET) == -1) goto fail;
    }
    return;

 fail:
    JNU_ThrowIOExceptionWithLastError(env, "setLength failed");
}

// jdk/src/solaris/native/java/io/io_util_md.h
#define IO_SetLength handleSetLength

// jdk/src/solaris/native/java/io/io_util_md.c
jint
handleSetLength(FD fd, jlong length)
{
    int result;
    RESTARTABLE(ftruncate64(fd, length), result);
    return result;
}
```

## 写入文件

```java
public void write(int b) throws IOException {
    write0(b);
}

public void write(byte b[]) throws IOException {
    writeBytes(b, 0, b.length);
}

public void write(byte b[], int off, int len) throws IOException {
    writeBytes(b, off, len);
}
```

这三个write方法实现与FileOutputStream相同，可以参考[JDK源码阅读-FileOutputStream](http://imushan.com/2018/06/04/java/language/JDK%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB-FileOutputStream/)

## 读取Java数据类型方法

`RandomAccessFile`还提供了读取Java数据类型的方法，这些方法与`DataInputStream`和`DataOutputStream`中提供的一样。

```java
boolean readBoolean()
byte readByte()
int readUnsignedByte()
short readShort()
int readUnsignedShort()
char readChar()
int readInt()
long readLong()
float readFloat()
double readDouble()
String readLine()
String readUTF()
```

```java
void writeBoolean(boolean v)
void writeByte(int v)
void writeShort(int v)
void writeChar(int v)
void writeInt(int v)
void writeLong(long v)
void writeFloat(float v)
void writeDouble(double v)
void writeBytes(String s)
void writeChars(String s)
void writeUTF(String str)
```

这些方法都是调用`RandomAccessFile`中基础的read/write方法实现的。

