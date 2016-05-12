---
title: 学习Redis-安装与基本使用
date: 2016-05-12 14:16:49
tags: [db,redis]
---

## 安装Redis
环境：CentOS 6.7

```
$ wget http://download.redis.io/releases/redis-3.2.0.tar.gz
$ tar xzf redis-3.2.0.tar.gz
$ cd redis-3.2.0
$ make
$ make install
```

## 启动Redis
### 直接启动

    redis-server

默认端口是：6379

### 使用初始化脚本启动
Redis的源代码目录的utils/redis_init_script是官方提供的一个启动停止Redis的脚本，可以用来让Linux开机自动启动Redis，推荐使用。

```
 #!/bin/sh
 #
 # Simple Redis init.d script conceived to work on Linux systems
 # as it does use of the /proc filesystem.

 REDISPORT=6379
 EXEC=/usr/local/bin/redis-server
 CLIEXEC=/usr/local/bin/redis-cli

 PIDFILE=/var/run/redis_${REDISPORT}.pid
 CONF="/etc/redis/${REDISPORT}.conf"

 case "$1" in
     start)
         if [ -f $PIDFILE ]
         then
                 echo "$PIDFILE exists, process is already running or crashed"
         else
                 echo "Starting Redis server..."
                 $EXEC $CONF
         fi
         ;;
     stop)
         if [ ! -f $PIDFILE ]
         then
                 echo "$PIDFILE does not exist, process is not running"
         else
                 PID=$(cat $PIDFILE)
                 echo "Stopping ..."
                 $CLIEXEC -p $REDISPORT shutdown
                 while [ -x /proc/${PID} ]
                 do
                     echo "Waiting for Redis to shutdown ..."
                     sleep 1
                 done
                 echo "Redis stopped"
         fi
         ;;
     *)
         echo "Please use start or stop as first argument"
         ;;
 esac
```

使用该脚本的步骤：
1. 复制脚本到/etc/init.d目录中，文件名为`redis_端口号`，然后修改文件中`REDISPORT=端口号`，第二行添加`#chkconfig: 345 60 60`（为了支持CentOS的chkconfig）
2. 建立需要的文件夹：

  `/etc/redis` 存放Redis的配置文件
  `/var/redis/端口号` 存放Redis的持久化文件

3. 修改配置文件：

  复制配置文件模板到`/etc/redis`（在redis源码目录中的redis.conf），命名为`端口号.conf`。修改其配置：

  - daemonize yes 使Redis以守护进程运行
  - pidfile /var/run/redis_端口号.pid 设置Redis的PID文件位置
  - port 端口号
  - dir /var/redis/端口号 设置持久化文件存放位置

然后就可以启动Redis：

    $ /etc/init.d/redis_端口号 start

让Redis随系统启动：

    CentOS中：
    $ sudo chkconfig --add redis_端口号
    $ sudo chkconfig --level 2345 redis_端口号 on
    
    Ubuntu中：
    $ sudo update-rc.d redis_端口号 defaults

## 停止Redis
强制傻屌Redis进程有可能会导致内存中的数据丢失，所以停止Redis的方法是向Redis发送`SHUTDOWN`命令。

    $ redis-cli SHUTDOWN

或者

    $ kill redis进程PID

也可以，因为redis会处理`SIGTERM`信号

## 客户端连接Redis

    redis-cli -p 端口号


## 参考资料：
- 《Redis入门指南》
- [redis安装与参数说明 - 持续疯长，往天那边去 - ITeye技术网站](http://chembo.iteye.com/blog/2054021)
- [服务不支持chkconfig解决方法脚本 - 51CTO.COM](http://os.51cto.com/art/201006/207661.htm)
- [Redis](http://redis.io/download)
- ✨[Redis和Memcached的区别](http://www.biaodianfu.com/redis-vs-memcached.html)