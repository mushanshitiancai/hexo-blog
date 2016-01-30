---
title: python+selenium抓取网页
date: 2016-01-30 14:09:49
tags: [python]
---

一老友希望从Twitter上抓取特定主体的所有推文，打算用python+selenium试一下。

## 安装Selenium
目前Selenium支持的Python版本有2.7，3.2，3.3，3.4。我使用的是2.7。

    sudo pip install selenium

我在mac上安装遇到错误：

    OSError: [Errno 1] Operation not permitted: '/System/Library/Frameworks/Python.framework/Versions/2.7/selenium'

这是因为OSX El Capitan使用的新的安全策略不允许用户修改系统文件。系统的Python也处于保护之下。

对于这个问题可以使用Virtualenv这个工具。Virtualenv可以建立一个独立的Python运行环境。具体可以参加这个[教程][virtualenv]。

安装virtualenv并建立一个新Python环境：

```
sudo pip install virtualenv
virtualenv --no-site-packages test_env
source test_env/bin/activate              # 进入环境
pip install selenium                      # 这个时候安装已经不需要sudo了
deactivate                                # 退出环境
```

virtualenv解决了Python不能为每个项目独立设置包管理的问题。但是相较于npm的方式，还是很麻烦的。

## 基础使用

```
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()
driver.get("http://www.python.org")
assert "Python" in driver.title
elem = driver.find_element_by_name("q")
elem.send_keys("pycon")
elem.send_keys(Keys.RETURN)
assert "No results found." not in driver.page_source
driver.close()
```

这是官网上的demo。我们先把这个跑通了。我运行的时候提示错误：

```
raise WebDriverException("The browser appears to have exited "
selenium.common.exceptions.WebDriverException: Message: The browser appears to have exited before we could connect. If you specified a log_file in the FirefoxBinary constructor, check it for details.
```

再运行一次就不会报错。目前还不知道原因。

Python的官网使用了一些被墙的资源，所以我吧代码改成了中国版的，注意Python2.7中处理中文还是比较麻烦的：

```
# coding=utf-8
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()
driver.get("http://www.baidu.com")
assert u"百度" in driver.title
driver.close()
```

成功运行。

## 

目标链接：`https://twitter.com/search?q=%23%24aapl%20lang%3Aen%20since%3A2015-01-01%20until%3A2015-12-31&src=typd`。





## 参考链接
-  [Selenium with Python — Selenium Python Bindings 2 documentation](http://selenium-python.readthedocs.org/)
- [ipython - OSX El Capitan: sudo pip install OSError: [Errno: 1] Operation not permitted - Stack Overflow](http://stackoverflow.com/questions/33004708/osx-el-capitan-sudo-pip-install-oserror-errno-1-operation-not-permitted)
- [Virtualenv — virtualenv 14.0.3 documentation](https://virtualenv.pypa.io/en/latest/index.html)

[virtualenv]: http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432712108300322c61f256c74803b43bfd65c6f8d0d0000 "virtualenv - 廖雪峰的官方网站"
[Getting started - ChromeDriver - WebDriver for Chrome]: https://sites.google.com/a/chromium.org/chromedriver/getting-started "Getting started - ChromeDriver - WebDriver for Chrome"