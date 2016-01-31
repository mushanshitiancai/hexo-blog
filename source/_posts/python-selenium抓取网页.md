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

## 使用代理
目标链接：`https://twitter.com/search?q=%23%24aapl%20lang%3Aen%20since%3A2015-01-01%20until%3A2015-12-31&src=typd`。是Twitter的一个网址。还是必须得翻墙。

我使用的翻墙方法是在mac下使用chrome+shadowsocks。但是mac下的Firefox似乎无法使用系统代理，导致不能像chrome那样使用系统代理翻墙，需要手工指定。

而使用selenium启动的Firefox，并不会使用你正常启动的那个Firefox中的配置。需要在程序中指定([参考地址][firefox_proxy])。

```
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.proxy import *

myProxy = "127.0.0.1:1080"

proxy = Proxy({
    'proxyType': ProxyType.MANUAL,
    # 'httpProxy': myProxy,
    # 'ftpProxy': myProxy,
    # 'sslProxy': myProxy,
    'socksProxy': myProxy,
    'noProxy': '' # set this value as desired
    })
driver = webdriver.Firefox(proxy=proxy)
driver.get("https://twitter.com/search?q=%23%24aapl%20lang%3Aen%20since%3A2015-01-01%20until%3A2015-12-31&src=typd")
# driver.close()
```

但是Firefox对代理的支持还是不尽如人意，通用使用代理，比chrome的速度慢了很多，而且还打不开。。。

## 使用ChromeDriver
ChromeDriver是用来控制Chrome的WebDriver。默认selenium不会提供ChromeDriver，需要自己去下载([地址][ChromeDriver])。

下载后把chromedriver这个可执行文件放到一个特定目录下。使用ChromeDriver需要制定这个路径的：

```
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Chrome("/Users/mazhibin/software/chromedriver")
driver.get("https://twitter.com/search?q=%23%24aapl%20lang%3Aen%20since%3A2015-01-01%20until%3A2015-12-31&src=typd")
# driver.close()
```

很好，这些启动了Chrome，而且使用了系统代理，很快就打开了页面。（为什么Firefox一直打不开呢？）

## 获取页面内容
通过Chrome开发者工具分析Twitter页面。发现推文是在`tweet-text`这个类选择器中的。在selenium中如何获取呢？

首先是获取元素，selenium提供了一系列的函数来获取元素：

```
# 获取单个元素
find_element_by_id
find_element_by_name
find_element_by_xpath
find_element_by_link_text
find_element_by_partial_link_text
find_element_by_tag_name
find_element_by_class_name
find_element_by_css_selector

# 获取多个元素
find_elements_by_name
find_elements_by_xpath
find_elements_by_link_text
find_elements_by_partial_link_text
find_elements_by_tag_name
find_elements_by_class_name
find_elements_by_css_selector
```

这些函数返回`WebElement`对象。我们可以使用`WebElement`对象上属性和方法来获取信息：

```
属性：
text
tag_name

方法：
get_attribute(name)  # 获取元素的某属性
is_displayed()       # 是否系列
is_enabled()
is_selected()
find_...             # 之前的find系列在WebElement上也可以使用，表示寻找子元素
clear()
click()
screenshot(filename)
send_keys(*value)
submit()
value_of_css_property(property_name)
```

获取推文的text的demo如下：

```
driver = webdriver.Chrome(chromedriverPath)
driver.get(url)
items = driver.find_elements_by_css_selector(".tweet-text")
for item in items:
    print item.text
driver.close()
```

## 滚动页面
Twitter的页面是会在滚动到页面底部后自动加载的。现在由于很多网站是这样的。就是因为页面中的信息是通过js异步加载的所以才需要使用selenium来抓取，不然用经典的Python爬虫就很好了。

现在我们需要通过selenium控制页面。

如果selenium对所有页面可能的操作都定义一个包装函数，可想而知，工作量是非常大的。而这些操作，可以肯定的是js一定能做到。所以selenium通过管道使用户可以在页面中注入js，使自身变得非常强大。

```
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
```

这句代码可以让页面滚动到底部。



## 参考链接
-  [Selenium with Python — Selenium Python Bindings 2 documentation](http://selenium-python.readthedocs.org/)
- [ipython - OSX El Capitan: sudo pip install OSError: [Errno: 1] Operation not permitted - Stack Overflow](http://stackoverflow.com/questions/33004708/osx-el-capitan-sudo-pip-install-oserror-errno-1-operation-not-permitted)
- [Virtualenv — virtualenv 14.0.3 documentation](https://virtualenv.pypa.io/en/latest/index.html)
- [How can I scroll a web page using selenium webdriver in python? - Stack Overflow](http://stackoverflow.com/questions/20986631/how-can-i-scroll-a-web-page-using-selenium-webdriver-in-python)

[virtualenv]: http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432712108300322c61f256c74803b43bfd65c6f8d0d0000 "virtualenv - 廖雪峰的官方网站"
[firefox_proxy]: http://stackoverflow.com/questions/18719980/proxy-selenium-python-firefox "Proxy Selenium Python Firefox - Stack Overflow"
[ChromeDriver]: https://sites.google.com/a/chromium.org/chromedriver/getting-started "Getting started - ChromeDriver - WebDriver for Chrome"