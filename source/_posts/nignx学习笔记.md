---
title: nignx学习笔记
date: 2016-01-23 21:08:25
tags: [nginx]
---

读书：《深入理解Nginx》

## install

install necessary tools

    yum install -y gcc g++ pcre pcre-devel zlib zlib-devel openssl openssl-devel

download source code:

    wget http://nginx.org/download/nginx-1.0.15.tar.gz  # or
    wget http://nginx.org/download/nginx-1.8.0.tar.gz
    
    tar -zxvf nginx-1.0.15.tar.gz

install

    ./configure
    make
    make install

## control nginx through command

    start:    
    /usr/local/nginx/sbin/nginx
    
    fast stop:
    /usr/local/nginx/sbin/nginx -s stop
    
    quit after done all request:
    /usr/local/nginx/sbin/nginx -s stop
    
    reload config:
    /usr/local/nginx/sbin/nginx -s reload
    
    reopen log file(use to backup log file,but how?):
    /usr/local/nginx/sbin/nginx -s reopen
    
    smooth update nginx:
    kill -s SIGUSR2 <nginx master pid>
    /usr/local/nginx/sbin/nginx              <- new nginx
    kill -s SIGQUIT <old nginx master pid>

## configure of nginx

basic format:

    configurename value1 value2;

# Nginx+PHP

1. install base tools

        yum install -y libxml2 libxml2-devel

2. download php([PHP: Downloads](http://php.net/downloads.php))
3. install php
        
        tar -zxvf php-5.6.15.tar.gz
        cd php-5.6.15
        ./configure --prefix=/usr/local/php --enable-fpm
        make && make install

        cd /usr/local/php/etc
        cp php-fpm.conf.default php-fpm.conf
        sudo /usr/local/php/sbin/php-fpm

    
    location ~ \.php$ {
        root html/hello;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html/hllo$fastcgi_script_name;
        include fastcgi_params;
    }

    FastCGI sent in stderr: "Primary script unknown" while reading response header from upstream
    
    solution：
    fastcgi_param SCRIPT_FILENAME html/hllo$fastcgi_script_name;
    ->
    fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html/hllo$fastcgi_script_name;

    yum  -y install mysql mysql-server mysql-devel



好文：
[Nginx安装与使用 - 吴秦 - 博客园](http://www.cnblogs.com/skynet/p/4146083.html)
[Nginx + CGI/FastCGI + C/Cpp - 吴秦 - 博客园](http://www.cnblogs.com/skynet/p/4173450.html)

[centos安装php php-fpm - zxpo - 博客园](http://www.cnblogs.com/zxpo/p/3798983.html)
[如何正确配置Nginx+PHP | 火丁笔记](http://huoding.com/2013/10/23/290)







