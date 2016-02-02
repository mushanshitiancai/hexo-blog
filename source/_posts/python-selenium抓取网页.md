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

现在的逻辑是，我需要在页面滚动到底部后，等待页面加载完成，再滚动到底部，再等待。重复十次，最后获取此时页面上的所有推文。

如果我直接重复上面的代码十次，是没有这个效果的。因为`execute_script`会立马返回，不会等待页面再次加载完成的。所以这个时候就需要`wait`系列函数了。

## 等待页面发生变化
大部分操作，是会导致页面变化的，页面变化后再进行下一步操作也是最常见的做法。为了让程序可以觉察到页面发生了变化，selenium提供了一系列等待页面发生变化的函数。

等待分为两种。一种是明确的等待，比如我知道点击这个按钮后，页面会多一个元素。另外一种是不明确等待，~~不明确等待因为不知道页面会发生什么变化，所以笼统地等待一定的时间。~~ 前面的这种理解是错的。不明确等待，是指本来selenium在获取页面DOM元素时，是不会等待的，没有就是没有，而如果设置了不明确等待，那么如果没有获取到页面元素，会等待一定的时间。

明确等待的例子：

```
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Firefox()
driver.get("http://somedomain/url_that_delays_loading")
try:
    element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "myDynamicElement"))
    )
finally:
    driver.quit()
```

expected_conditions中可以使用的条件有：

```
title_is
title_contains
presence_of_element_located
visibility_of_element_located
visibility_of
presence_of_all_elements_located
text_to_be_present_in_element
text_to_be_present_in_element_value
frame_to_be_available_and_switch_to_it
invisibility_of_element_located
element_to_be_clickable - it is Displayed and Enabled.
staleness_of
element_to_be_selected
element_located_to_be_selected
element_selection_state_to_be
element_located_selection_state_to_be
alert_is_present
```

不明确等待可以这么用：

```
from selenium import webdriver

driver = webdriver.Firefox()
driver.implicitly_wait(10) # seconds
driver.get("http://somedomain/url_that_delays_loading")
myDynamicElement = driver.find_element_by_id("myDynamicElement")
```

selenium似乎没有直接让浏览器等待几秒的做法。只能使用明确等待的系列函数。

现在回到Twitter的页面逻辑上。页面在滚动到底部后，页面上啥元素也不会边，底下也不会变成“正在加载”什么的（Twitter真是偷懒啊。。。）只能通过页面中推文的个数来确定了。

第一次页面会加载13个推文，之后每次都会加载13个，所以通过个数可以判断加载完成了。可以使用css的选择器，来实现这个效果。推文都是在`#stream-items-id`这个ol中的，其中的第一个li是标题，所以第2-14个是推文，如果第27个推文出现了，说明第一次的刷新成功了。

"#stream-items-id >li:nth-of-type(28)"

所以在页面滚动后，需要等待最新的一条推文出现，再继续滚动。最终的程序如下：

```
# coding=utf-8
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import csv
import codecs
import sys  
reload(sys)  
sys.setdefaultencoding('utf-8')

def crawl(url):
    chromedriverPath = "/Users/mazhibin/software/chromedriver"

    # twitter每次更新13条
    eachCount = 13

    # 滚动几次。滚动次数越多，采集的数据越多
    scrollTimes = 10

    # driver = webdriver.Firefox()
    driver = webdriver.Chrome(chromedriverPath)
    driver.get(url)

    try:
        for i in range(scrollTimes):
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        
            lastTweetCss = "#stream-items-id >li:nth-of-type(" + str(eachCount*(i+2)+1) + ") .tweet-text"
            print lastTweetCss
            elem = WebDriverWait(driver,20).until(EC.visibility_of_element_located((By.CSS_SELECTOR,lastTweetCss)))
            printTweet(driver)
    finally:
        driver.close()


def printTweet(driver):
    tweetCss = "[data-item-type=tweet]"
    nameCss = ".fullname"
    timeCss = "._timestamp"
    contentCss = ".tweet-text"

    items = driver.find_elements_by_css_selector(tweetCss)
    resultArr = []
    for i,item in enumerate(items):
        try:
            nameElem = item.find_element_by_css_selector(nameCss)
            timeElem = item.find_element_by_css_selector(timeCss)
            contentElem = item.find_element_by_css_selector(contentCss)

            name = nameElem.text
            time = timeElem.text
            content = contentElem.text

            resultArr.append([name,time,content])
            print("%d: name=%s time=%s content=%s" % (i,name,time,content))
        except Exception, e:
            print("error index=%d" % (i))
            print e

    printToCsv(resultArr)


def printToCsv(data):
    writer = csv.writer(codecs.open('result.csv','wb','gbk'))
    writer.writerow(['name','time','content'])

    for item in data:
        writer.writerow(item)


if __name__ == '__main__':
    url = "https://twitter.com/search?q=%23%24aapl%20lang%3Aen%20since%3A2015-01-01%20until%3A2015-12-31&src=typd"
    crawl(url)
```


## 参考链接
-  [Selenium with Python — Selenium Python Bindings 2 documentation](http://selenium-python.readthedocs.org/)
- [ipython - OSX El Capitan: sudo pip install OSError: [Errno: 1] Operation not permitted - Stack Overflow](http://stackoverflow.com/questions/33004708/osx-el-capitan-sudo-pip-install-oserror-errno-1-operation-not-permitted)
- [Virtualenv — virtualenv 14.0.3 documentation](https://virtualenv.pypa.io/en/latest/index.html)
- [How can I scroll a web page using selenium webdriver in python? - Stack Overflow](http://stackoverflow.com/questions/20986631/how-can-i-scroll-a-web-page-using-selenium-webdriver-in-python)

[virtualenv]: http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432712108300322c61f256c74803b43bfd65c6f8d0d0000 "virtualenv - 廖雪峰的官方网站"
[firefox_proxy]: http://stackoverflow.com/questions/18719980/proxy-selenium-python-firefox "Proxy Selenium Python Firefox - Stack Overflow"
[ChromeDriver]: https://sites.google.com/a/chromium.org/chromedriver/getting-started "Getting started - ChromeDriver - WebDriver for Chrome"