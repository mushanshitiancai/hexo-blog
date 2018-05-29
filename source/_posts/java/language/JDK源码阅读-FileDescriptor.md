---
title: JDK源码阅读-FileDescriptor
date: 2018-05-29 22:20:49
categories: [Java,JDK源码阅读]
tags: java
toc: true
---

操作系统使用文件描述符来指代一个打开的文件，对文件的读写操作，都需要文件描述符作为参数。Java虽然在设计上使用了抽象程度更高的流来作为文件操作的模型，但是底层依然要使用文件描述符与操作系统交互，而Java世界里文件描述符的对应类就是FileDescriptor。

<!-- more -->

Java文件操作的三个类：`FileIntputStream`，`FileOutputStream`，`RandomAccessFile`，打开这些类的源码可以看到都有一个FileDescriptor成员变量。

注：本文使用的JDK版本为8。

## FileDescriptor与文件描述符

操作系统中的文件描述符本质上是一个非负整数，其中0,1,2固定为标准输入，标准输出，标准错误输出，程序接下来打开的文件使用当前进程中最小的可用的文件描述符号码，比如3。

文件描述符本身就是一个整数，所以FileDescriptor的核心职责就是保存这个数字：

```java
public final class FileDescriptor {
    private int fd;
}
```

但是文件描述符是无法在Java代码里设置的，因为FileDescriptor只有私有和无参的构造函数：

```java
public FileDescriptor() {
    fd = -1;
}

private FileDescriptor(int fd) {
    this.fd = fd;
}
```

那Java是在何时会设置FileDescriptor的fd字段呢？这要结合`FileIntputStream`，`FileOutputStream`，`RandomAccessFile`的代码来看了。

我们以`FileInputStream`为例，首先，`FileInputStream`有一个`FileDescriptor`成员变量：

```java
public class FileInputStream extends InputStream
{
    private final FileDescriptor fd;
```

在`FileInputStream`实例化时，会新建`FileDescriptor`实例，并使用`fd.attach(this)`关联`FileInputStream`实例与`FileDescriptor`实例，这是为了日后关闭文件描述符做准备。

```java
public FileInputStream(File file) throws FileNotFoundException {
    String name = (file != null ? file.getPath() : null);
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

但是上面的代码也没有对`FileDescriptor#fd`进行赋值，实际上Java层面无法对他赋值，真正的逻辑是在`FileInputStream#open0`这个native方法中，这就要下载JDK的源码来看了：

```cpp
// /jdk/src/share/native/java/io/FileInputStream.c
JNIEXPORT void JNICALL
Java_java_io_FileInputStream_open(JNIEnv *env, jobject this, jstring path) {
    fileOpen(env, this, path, fis_fd, O_RDONLY);
}

// /jdk/src/solaris/native/java/io/io_util_md.c
void
fileOpen(JNIEnv *env, jobject this, jstring path, jfieldID fid, int flags)
{
    WITH_PLATFORM_STRING(env, path, ps) {
        FD fd;

#if defined(__linux__) || defined(_ALLBSD_SOURCE)
        /* Remove trailing slashes, since the kernel won't */
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

可以看到JDK的JNI代码中，使用`JVM_Open`打开文件，得到文件描述符，而`JVM_Open`已经不是JDK的方法了，而是JVM提供的方法，所以我们需要在hotspot中寻找其实现：

```cpp
// /hotspot/src/share/vm/prims/jvm.cpp
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

// /hotspot/src/os/linux/vm/os_linux.cpp
int os::open(const char *path, int oflag, int mode) {

  if (strlen(path) > MAX_PATH - 1) {
    errno = ENAMETOOLONG;
    return -1;
  }
  int fd;
  int o_delete = (oflag & O_DELETE);
  oflag = oflag & ~O_DELETE;

  fd = ::open64(path, oflag, mode);  // 调用open64打开文件
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

可以看到JVM最后使用`open64`这个方法打开文件，`open64`其实是一个宏定义，在unix环境下，最终使用的函数是`open`：

`/jdk/src/solaris/native/sun/nio/fs/UnixNativeDispatcher.c`
```cpp
#define stat64 stat
#define statvfs64 statvfs

#define open64 open
#define fstat64 fstat
#define lstat64 lstat
#define dirent64 dirent
#define readdir64_r readdir_r
```

这里的open不是我们以前学C语言时打开文件用的fopen函数，fopen是C标准库里的函数，而open不是，open是POSIX规范中的函数，是不带缓冲的I/O，不带缓冲的I/O相关的函数还有read，write，lseek，close，不带缓冲指的是这些函数都调用内核中的一个系统调用，而C标准库为了减少系统调用，使用了缓存来减少read，write的内存调用。（参考《UNIX环境高级编程》）

通过上面的代码跟踪，我们知道了`FileInputStream#open`是使用open系统调用来打开文件，得到文件句柄，现在我们的问题要回到这个文件句柄是如何最终设置到`FileDescriptor#fd`，我们来看`/jdk/src/solaris/native/java/io/io_util_md.c:fileOpen`的关键代码：

```c
fd = handleOpen(ps, flags, 0666);
if (fd != -1) {
    SET_FD(this, fd, fid);
} else {
    throwFileNotFoundException(env, path);
}
```

如果文件描述符fd正确，通过`SET_FD`这个红设置到`fid`对应的成员变量上：

```c
#define SET_FD(this, fd, fid) \
    if ((*env)->GetObjectField(env, (this), (fid)) != NULL) \
        (*env)->SetIntField(env, (*env)->GetObjectField(env, (this), (fid)),IO_fd_fdID, (fd))
```

`SET_FD`宏比较简单，获取`FileInputStream`上的`fid`这个字段ID对应的字段，然后设置这个字段的`IO_fd_fdID`对应的字段（`FileDescriptor#fd`）为文件描述符。

那这个`fid`和`IO_fd_fdID`是哪里来的呢？在`/jdk/src/share/native/java/io/FileInputStream.c`的开头，可以看到这样的代码：

```c
jfieldID fis_fd; /* id for jobject 'fd' in java.io.FileInputStream */

/**************************************************************
 * static methods to store field ID's in initializers
 */

JNIEXPORT void JNICALL
Java_java_io_FileInputStream_initIDs(JNIEnv *env, jclass fdClass) {
    fis_fd = (*env)->GetFieldID(env, fdClass, "fd", "Ljava/io/FileDescriptor;");
}
```

`Java_java_io_FileInputStream_initIDs`对应`FileInputStream`中static块调用的`initIDs`函数：

```java
public class FileInputStream extends InputStream
{
    /* File Descriptor - handle to the open file */
    private final FileDescriptor fd;

    static {
        initIDs();
    }

    private static native void initIDs();
    // ...
}
```

还有`jdk/src/solaris/native/java/io/FileDescriptor_md.c`开头：

```c
/* field id for jint 'fd' in java.io.FileDescriptor */
jfieldID IO_fd_fdID;

/**************************************************************
 * static methods to store field ID's in initializers
 */

JNIEXPORT void JNICALL
Java_java_io_FileDescriptor_initIDs(JNIEnv *env, jclass fdClass) {
    IO_fd_fdID = (*env)->GetFieldID(env, fdClass, "fd", "I");
}
```

`Java_java_io_FileDescriptor_initIDs`对应`FileDescriptor`中static块调用的`initIDs`函数：

```java
public final class FileDescriptor {

    private int fd;

    static {
        initIDs();
    }

    /* This routine initializes JNI field offsets for the class */
    private static native void initIDs();
}
```

从代码可以看出这样的一个流程：

1. JVM加载FileDescriptor类，执行static块中的代码
2. 执行static块中的代码时，执行initIDs本地方法
3. initIDs本地方法只做了一件事情，就是获取fd字段ID，并保存在IO_fd_fdID变量中
4. JVM加载FileInputStream类，执行static块中的代码
5. 执行static块中的代码时，执行initIDs本地方法
6. initIDs本地方法只做了一件事情，就是获取fd字段ID，并保存在fis_fd变量中
7. 后续逻辑直接使用IO_fd_fdID和fis_fd

为什么会有这样一个奇怪的初始化过程呢，为什么要专门弄一个initIDs方法来提前保存字段ID呢？这是因为特定类的字段ID在一次Java程序的声明周期中是不会变化的，而获取字段ID本身是一个比较耗时的过程，因为如果字段是从父类继承而来，JVM需要遍历继承树来找到这个字段，所以JNI代码的最佳实践就是对使用到的字段ID做缓存。（参考[使用 Java Native Interface 的最佳实践](http://www.ibm.com/developerworks/cn/java/j-jni/index.html)）

## 标准输入，标准输出，标准错误输出

标准输入，标准输出，标准错误输出是所有操作系统都支持的，对于一个进程来说，文件描述符0,1,2固定是标准输入，标准输出，标准错误输出。

Java对标准输入，标准输出，标准错误输出的支持也是通过FileDescriptor实现的，`FileDescriptor`中定义了in，out，err这三个静态变量：

```java
public static final FileDescriptor in = new FileDescriptor(0);
public static final FileDescriptor out = new FileDescriptor(1);
public static final FileDescriptor err = new FileDescriptor(2);
```

我们常用的`System.out`等，就是基于这三个封装的：

```java
public final class System {
    public final static InputStream in = null;
    public final static PrintStream out = null;
    public final static PrintStream err = null;

    /**
    * Initialize the system class.  Called after thread initialization.
    */
    private static void initializeSystemClass() {
        FileInputStream fdIn = new FileInputStream(FileDescriptor.in);
        FileOutputStream fdOut = new FileOutputStream(FileDescriptor.out);
        FileOutputStream fdErr = new FileOutputStream(FileDescriptor.err);
        setIn0(new BufferedInputStream(fdIn));
        setOut0(newPrintStream(fdOut, props.getProperty("sun.stdout.encoding")));
        setErr0(newPrintStream(fdErr, props.getProperty("sun.stderr.encoding")));
    }

    private static native void setIn0(InputStream in);
    private static native void setOut0(PrintStream out);
    private static native void setErr0(PrintStream err);
}
```

System作为一个特殊的类，类构造时无法实例化`in/out/err`，构造发生在`initializeSystemClass`被调用时，但是`in/out/err`是被声明为final的，如果声明时和类构造时没有赋值，是会报错的，所以System在实现时，先设置为null，然后通过native方法来在运行时修改（学到了不少奇技淫巧。。），通过`setIn0/setOut0/setErr0`的注释也可以说明这一点：

```c
/*
 * The following three functions implement setter methods for
 * java.lang.System.{in, out, err}. They are natively implemented
 * because they violate the semantics of the language (i.e. set final
 * variable).
 */
JNIEXPORT void JNICALL
Java_java_lang_System_setIn0(JNIEnv *env, jclass cla, jobject stream)
{
    jfieldID fid =
        (*env)->GetStaticFieldID(env,cla,"in","Ljava/io/InputStream;");
    if (fid == 0)
        return;
    (*env)->SetStaticObjectField(env,cla,fid,stream);
}

JNIEXPORT void JNICALL
Java_java_lang_System_setOut0(JNIEnv *env, jclass cla, jobject stream)
{
    jfieldID fid =
        (*env)->GetStaticFieldID(env,cla,"out","Ljava/io/PrintStream;");
    if (fid == 0)
        return;
    (*env)->SetStaticObjectField(env,cla,fid,stream);
}

JNIEXPORT void JNICALL
Java_java_lang_System_setErr0(JNIEnv *env, jclass cla, jobject stream)
{
    jfieldID fid =
        (*env)->GetStaticFieldID(env,cla,"err","Ljava/io/PrintStream;");
    if (fid == 0)
        return;
    (*env)->SetStaticObjectField(env,cla,fid,stream);
}
```

## FileDescriptor关闭逻辑

`FileDescriptor`的代码不多，除了上面提到的`fd`成员变量，`initIDs`初始化构造方法，`in/out/err`三个标准描述符，只剩下`attach`和`closeAll`这两个方法，这两个方法和文件描述符的关闭有关。

上文提到过，`FileInputStream`在实例化时，会新建`FileDescriptor`并调用`FileDescriptor#attach`方法绑定文件流与文件描述符。

```java
public FileInputStream(File file) throws FileNotFoundException {
    String name = (file != null ? file.getPath() : null);
    fd = new FileDescriptor();
    fd.attach(this);
    path = name;
    open(name);
}
```

`FileDescriptor#attach`实现如下：

```java
synchronized void attach(Closeable c) {
    if (parent == null) {
        // first caller gets to do this
        parent = c;
    } else if (otherParents == null) {
        otherParents = new ArrayList<>();
        otherParents.add(parent);
        otherParents.add(c);
    } else {
        otherParents.add(c);
    }
}
```

如果`FileDescriptor`只和一个`FileInputStream/FileOutputStream/RandomAccessFile`有关联，则只是简单的保存到`parent`成员中，如果有多个`FileInputStream/FileOutputStream/RandomAccessFile`有关联，则所有关联的`Closeable`都保存到`otherParents`这个`ArrayList`中。

这里其实有个细节，就是`parent`变量其实只在这个函数有用到，所以上面的逻辑完全可以写成无论`FileDescriptor`和几个`Closeable`对象有关联，都直接保存到`otherParents`这个`ArrayList`即可，但是极大的概率，一个`FileDescriptor`只会和一个`FileInputStream/FileOutputStream/RandomAccessFile`有关联，只有用户调用`FileInputStream(FileDescriptor fdObj)`这样样的构造函数才会出现多个`Closeable`对象对应一个`FileDescriptor`的情况，这里其实是做了优化，在大概率的情况下不新建`ArrayList`，减少一个对象的创建开销。

接着看看`FileInputStream`如何进行关闭操作，如何关闭关联的`FileDescriptor`：

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

private native void close0() throws IOException;
```

首先通过锁保证关闭流程不会被并发调用，设置成员`closed`为`true`，接着关闭关联的Channel，这个以后分析NIO的时候再来说。接着就是关闭`FileDescriptor`了。

`FileDescriptor`没有提供`close`方法，而是提供了一个`closeAll`方法：

```java
synchronized void closeAll(Closeable releaser) throws IOException {
    if (!closed) {
        closed = true;
        IOException ioe = null;
        try (Closeable c = releaser) {
            if (otherParents != null) {
                for (Closeable referent : otherParents) {
                    try {
                        referent.close();
                    } catch(IOException x) {
                        if (ioe == null) {
                            ioe = x;
                        } else {
                            ioe.addSuppressed(x);
                        }
                    }
                }
            }
        } catch(IOException ex) {
            /*
             * If releaser close() throws IOException
             * add other exceptions as suppressed.
             */
            if (ioe != null)
                ex.addSuppressed(ioe);
            ioe = ex;
        } finally {
            if (ioe != null)
                throw ioe;
        }
    }
}
```

`FileDescriptor`的关闭流程有点绕，效果是会把关联的`Closeable`对象（其实只可能是`FileInputStream/FileOutputStream/RandomAccessFile`，而这三个类的`close`方法实现是一模一样的）通通都关闭掉（效果是这些对象的`closed`设置为true，关联的Channel关闭，这样这个对象就无法使用了），最后这些关联的对象中，只会有一个对象的`close0`本地方法被调用，这个方法中调用系统调用`close`来真正关闭文件描述符：

```c
// /jdk/src/solaris/native/java/io/FileInputStream_md.c
JNIEXPORT void JNICALL
Java_java_io_FileInputStream_close0(JNIEnv *env, jobject this) {
    fileClose(env, this, fis_fd);
}

// /jdk/src/solaris/native/java/io/io_util_md.c
void fileClose(JNIEnv *env, jobject this, jfieldID fid)
{
    FD fd = GET_FD(this, fid);
    if (fd == -1) {
        return;
    }

    /* Set the fd to -1 before closing it so that the timing window
     * of other threads using the wrong fd (closed but recycled fd,
     * that gets re-opened with some other filename) is reduced.
     * Practically the chance of its occurance is low, however, we are
     * taking extra precaution over here.
     */
    SET_FD(this, -1, fid);

    // 尝试关闭0，1，2文件描述符，需要特殊的操作。首先这三个是不能关闭的，
    // 如果关闭的，后续打开的文件就会占用这三个描述符，
    // 所以合理的做法是把要关闭的描述符指向/dev/null，实现关闭的效果
    // 不过Java代码中，正常是没办法关闭0，1，2文件描述符的
    if (fd >= STDIN_FILENO && fd <= STDERR_FILENO) {
        int devnull = open("/dev/null", O_WRONLY);
        if (devnull < 0) {
            SET_FD(this, fd, fid); // restore fd
            JNU_ThrowIOExceptionWithLastError(env, "open /dev/null failed");
        } else {
            dup2(devnull, fd);
            close(devnull);
        }
    } else if (close(fd) == -1) { // 关闭非0，1，2的文件描述符只是调用close系统调用
        JNU_ThrowIOExceptionWithLastError(env, "close failed");
    }
}
```

在回头来讨论一个问题，就是为什么关闭一个`FileInputStream/FileOutputStream/RandomAccessFile`，就要把他关联的文件描述符所关联的所有`FileInputStream/FileOutputStream/RandomAccessFile`对象都关闭呢？

这个可以看看`FileInputStream#close`的JavaDoc：

```
Closes this file input stream and releases any system resources
associated with the stream.

If this stream has an associated channel then the channel is closed
as well.
```

也就是说`FileInputStream#close`是会吧输入/出流对应的系统资源关闭的，也就是输入/出流对应的文件描述符会被关闭，而如果这个文件描述符还关联这其他输入/出流，如果文件描述符都被关闭了，这些流自然也就不能用了，所以closeAll里把这些关联的流通通都关闭掉，使其不再可用。

## 总结

- `FileDescriptor`的作用是保存操作系统中的文件描述符
- `FileDescriptor`实例会被`FileInputStream/FileOutputStream/RandomAccessFile`持有，这三个类在打开文件时，在JNI代码中使用`open`系统调用打开文件，得到文件描述符在JNI代码中设置到`FileDescriptor`的`fd`成员变量上
- 关闭`FileInputStream/FileOutputStream/RandomAccessFile`时，会关闭底层对应的文件描述符，如果此文件描述符被多个`FileInputStream/FileOutputStream/RandomAccessFile`对象持有，则这些对象都会被关闭。关闭是文件底层是通过调用`close`系统调用实现的。

## 参考资料
- 《UNIX环境高级编程》
- [每天进步一点点——Linux中的文件描述符与打开文件之间的关系 - CSDN博客](https://blog.csdn.net/cywosp/article/details/38965239)
- [UNIX再学习 -- 文件描述符 - CSDN博客](https://blog.csdn.net/qq_29350001/article/details/65437279)
- [Linux探秘之用户态与内核态 - aCloudDeveloper - 博客园](https://www.cnblogs.com/bakari/p/5520860.html)
- [关于内核态和用户态切换开销的测试 - fireworks - 博客园](https://www.cnblogs.com/sfireworks/p/4428972.html)
- [系统调用真正的效率瓶颈在哪里？ - 知乎](https://www.zhihu.com/question/32043825)
- [使用 Java Native Interface 的最佳实践](http://www.ibm.com/developerworks/cn/java/j-jni/index.html)
- [java - Why closing an Input Stream closes the associated File Descriptor as well, even the File Descriptor is shared among multiple streams ? - Stack Overflow](https://stackoverflow.com/questions/34980241/why-closing-an-input-stream-closes-the-associated-file-descriptor-as-well-even)

