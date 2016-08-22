---
title: Mongify可行性研究（失败）
date: 2016-08-12 09:59:21
categories:
tags: [db,mongodb]
---

Mongify是一个迁移SQL数据库数据到MongoDB的Ruby工具。最近有项目需要把数据从SQLServer迁移到MongoDB，所以来看看这个工具好使不。

Mongify支持很多SQL数据库，包含MySQL, PostgreSQL, SQLite, Oracle, SQLServer, and DB2，但是作者只在MySql和SQLite上测试过。

大家可以看看[官网][Mongify]上的视频，很直观。

## 安装

```
gem install mongify
```

遇到错误：

```
ERROR:  While executing gem ... (Gem::DependencyError)
    Unable to resolve dependencies: mongify requires bson (>= 1.10.2); bson_ext requires bson (~> 1.12.5); mongo requires bson (~> 4.0)
```

参考官网的[issue][Unable to resolve dependencies: ubuntu · Issue #99 · anlek/mongify]，应该是我本机的ruby太久了，需要升级。可以使用rvm来管理ruby版本：

```
$ ruby -v
ruby 2.0.0p645 (2015-04-13 revision 50299) [universal.x86_64-darwin15]

$ curl -sSL https://get.rvm.io | bash -s stable
$ source ~/.profile
$ rvm install 2.3.1
$ rvm use 2.3.1 --default
```

再次安装mongify成功。

## 编写配置文件

```
sql_connection do
  adapter     "sqlserver"
  host        "172.31.102.6"
  username    "enterpriseuser"
  password    "qwe123"
  database    "FS.NetDisk"
  batch_size  10000
end

mongodb_connection do
  host        "localhost"
  database    "netdisk"
end
```

检查配置：

```
mongify check db.config
```

提示需要安装SQLServer的适配器

```
/Users/mazhibin/.rvm/rubies/ruby-2.3.1/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:55:in `require': Please install the sqlserver adapter: `gem install activerecord-sqlserver-adapter` (cannot load such file -- active_record/connection_adapters/sqlserver_adapter) (LoadError)
```

安装一下：

```
gem install activerecord-sqlserver-adapter
```

再次检查还有错误：

```
/Users/mazhibin/.rvm/rubies/ruby-2.3.1/lib/ruby/2.3.0/rubygems/specification.rb:2284:in `raise_if_conflicts': Please install the sqlserver adapter: `gem install activerecord-sqlserver-adapter` (Unable to activate activerecord-sqlserver-adapter-4.2.15, because activerecord-3.2.22.4 conflicts with activerecord (~> 4.2.1)) (LoadError)
```

看起来是版本冲突问题。

列出本地安装的ruby包：

```
$ gem list

*** LOCAL GEMS ***

activemodel (4.2.7.1, 3.2.22.4)
activerecord (4.2.7.1, 3.2.22.4)
activerecord-mysql-adapter (0.0.1)
activerecord-sqlserver-adapter (4.2.15)
activesupport (4.2.7.1, 3.2.22.4)
```

估计是应为本地有一套3.x版本的activerecord库，所以导致冲突了，删除它：

```
gem uninstall activemodel -v 3.2.22.4
gem uninstall activerecord -v 3.2.22.4
gem uninstall activesupport -v 3.2.22.4
```

再检查，提示

```
/Users/mazhibin/.rvm/rubies/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:319:in `to_specs': Could not find 'activerecord' (~> 3.2) - did find: [activerecord-4.2.7.1] (Gem::LoadError)
```

日了狗。。。看来作者没测试过就是高风险啊。。。弃

## 参考资料
- [Mongify][Mongify]
- [Unable to resolve dependencies: ubuntu · Issue #99 · anlek/mongify][Unable to resolve dependencies: ubuntu · Issue #99 · anlek/mongify]
- [ruby - Unable to activate susy-2.1.1, because sass-3.2.17 conflicts with sass (~> 3.3.0) - Stack Overflow](http://stackoverflow.com/questions/22576123/unable-to-activate-susy-2-1-1-because-sass-3-2-17-conflicts-with-sass-3-3-0)

[Mongify] :http://mongify.com/
[Unable to resolve dependencies: ubuntu · Issue #99 · anlek/mongify]: https://github.com/anlek/mongify/issues/99