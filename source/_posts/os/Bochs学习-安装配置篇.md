---
title: Bochs学习-安装配置篇
date: 2018-07-11 20:33:37
categories: [自己动手写操作系统]
tags: [bochs,os]
toc: true
---

最近想学习如何从零编写一个操作系统，现在关于这个的资料蛮多的，《操作系统真象还原》，就是一本神级别的书，看得我醍醐灌顶。其他的书籍还有《Orange'S:一个操作系统的实现》，《30天自制操作系统》。

自己动手写操作系统，虚拟机是必不可少的，虽然我们的目标是写出一个物理机可以安装可以运行的操作系统，但是用物理机会非常的麻烦也花钱。虚拟机中，vmware和virtualbox比较出名，但是却不适合我们的场景，因为这两个虚拟机更注重效率，所以会使用硬件级的虚拟化，所以在硬件调试上，功能有限，而bochs这个开源虚拟机，是用软件虚拟了所有的硬件，所以调试可以做到非常细的粒度，比如每次cpu执行命令，我们都可以暂停，看寄存器状态，看内存状态，这对于操作系统开发调试的帮助太大太大了。所以我们使用bochs这个虚拟机来。

<!-- mor -->

## Mac安装bochs

我的macOS的版本是10.13.2，使用brew大法安装bochs竟然报错了：

```
brew install bochs（bochs2.6.9安装失败）
cdrom_osx.cc:194:18: error: assigning to 'char *' from incompatible type 'const char *'
```

可能是因为系统版本较新，Xcode的某些升级导致编译源码不通过。

查阅了许多资料后，得到的正确安装步骤如下：

```
# 安装SDL
brew install sdl

# 先从官网下载bochs-2.6.tar.gz，地址https://sourceforge.net/projects/bochs/files/bochs/
$ tar -xvf bochs-2.6.tar.gz
$ wget https://raw.githubusercontent.com/Homebrew/formula-patches/e9b520dd4c/bochs/xcode9.patch
$ cd bochs-2.6
$ patch -p1 < ../xcode9.patch

修改config.cc的3621行
if (SIM->get_param_string("model", base)->getptr()>0) {
为
if (SIM->get_param_string("model", base)->getptr()>(char *)0) {

$ ./configure --enable-ne2000 \
            --enable-all-optimizations \
            --enable-cpu-level=6 \
            --enable-x86-64 \
            --enable-vmx=2 \
            --enable-pci \
            --enable-usb \
            --enable-usb-ohci \
            --enable-e1000 \
            --enable-debugger \
            --enable-disasm \
            --disable-debugger-gui \
            --with-sdl \
            --prefix=$HOME/software/bochs
$ make && make install
```

`--prefix=$HOME/software/bochs`这一句可以指定安装bochs到哪个目录下。

命令行中运行`bochs`，可以看到bochs的提示界面：

```
========================================================================
                        Bochs x86 Emulator 2.6
            Built from SVN snapshot on September 2nd, 2012
                  Compiled on May  5 2018 at 23:07:30
========================================================================
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [2]
```

说明信息中说，这个界面是用于指定启动什么虚拟机的。默认情况下bochs会搜索名为`boshcsrc.txt`的配置文件，并从配置文件中得到虚拟机信息，进而启动虚拟机。配置文件也可以叫别的名称，只要在这个界面指定配置文件名即可。

所以，在真正启动虚拟机之前，我们需要写一份配置文件。

## bochs配置文件

bochs的安装目录下的`bochs/share/doc/bochs/bochsrc-sample.txt`是配置文件的模板。这个文件非常详细，包含了所有的配置项与详细说明。我们需要的配置项有：

```
#=======================================================================
# MEGS
# Set the number of Megabytes of physical memory you want to emulate. 
# The default is 32MB, most OS's won't need more than that.
# The maximum amount of memory supported is 2048Mb.
# The 'MEGS' option is deprecated. Use 'MEMORY' option instead.
#=======================================================================
#megs: 256
#megs: 128
#megs: 64
#megs: 32
#megs: 16
#megs: 8

#=======================================================================
# ROMIMAGE:
# The ROM BIOS controls what the PC does when it first powers on.
# Normally, you can use a precompiled BIOS in the source or binary
# distribution called BIOS-bochs-latest. The ROM BIOS is usually loaded
# starting at address 0xf0000, and it is exactly 64k long. Another option
# is 128k BIOS which is loaded at address 0xe0000.
# You can also use the environment variable $BXSHARE to specify the
# location of the BIOS.
# The usage of external large BIOS images (up to 512k) at memory top is
# now supported, but we still recommend to use the BIOS distributed with
# Bochs. The start address optional, since it can be calculated from image size.
#=======================================================================
romimage: file=$BXSHARE/BIOS-bochs-latest 
#romimage: file=bios/seabios-1.6.3.bin
#romimage: file=mybios.bin, address=0xfff80000 # 512k at memory top

#=======================================================================
# VGAROMIMAGE
# You now need to load a VGA ROM BIOS into C0000.
#=======================================================================
#vgaromimage: file=bios/VGABIOS-elpin-2.40
vgaromimage: file=$BXSHARE/VGABIOS-lgpl-latest
#vgaromimage: file=bios/VGABIOS-lgpl-latest-cirrus

#=======================================================================
# FLOPPYA:
# Point this to pathname of floppy image file or device
# This should be of a bootable floppy(image/device) if you're
# booting from 'a' (or 'floppy').
#
# You can set the initial status of the media to 'ejected' or 'inserted'.
#   floppya: 2_88=path, status=ejected    (2.88M 3.5"  media)
#   floppya: 1_44=path, status=inserted   (1.44M 3.5"  media)
#   floppya: 1_2=path, status=ejected     (1.2M  5.25" media)
#   floppya: 720k=path, status=inserted   (720K  3.5"  media)
#   floppya: 360k=path, status=inserted   (360K  5.25" media)
#   floppya: 320k=path, status=inserted   (320K  5.25" media)
#   floppya: 180k=path, status=inserted   (180K  5.25" media)
#   floppya: 160k=path, status=inserted   (160K  5.25" media)
#   floppya: image=path, status=inserted  (guess media type from image size)
#   floppya: 1_44=vvfat:path, status=inserted  (use directory as VFAT media)
#   floppya: type=1_44                    (1.44M 3.5" floppy drive, no media)
#
# The path should be the name of a disk image file.  On Unix, you can use a raw
# device name such as /dev/fd0 on Linux.  On win32 platforms, use drive letters
# such as a: or b: as the path.  The parameter 'image' works with image files
# only. In that case the size must match one of the supported types.
# The parameter 'type' can be used to enable the floppy drive without media
# and status specified. Usually the drive type is set up based on the media type.
# The optional parameter 'write_protected' can be used to control the media
# write protect switch. By default it is turned off.
#=======================================================================
floppya: 1_44=/dev/fd0, status=inserted
#floppya: image=../1.44, status=inserted
#floppya: 1_44=/dev/fd0H1440, status=inserted
#floppya: 1_2=../1_2, status=inserted
#floppya: 1_44=a:, status=inserted
#floppya: 1_44=a.img, status=inserted, write_protected=1
#floppya: 1_44=/dev/rfd0a, status=inserted


#=======================================================================
# BOOT:
# This defines the boot sequence. Now you can specify up to 3 boot drives,
# which can be 'floppy', 'disk', 'cdrom' or 'network' (boot ROM).
# Legacy 'a' and 'c' are also supported.
# Examples:
#   boot: floppy
#   boot: cdrom, disk
#   boot: network, disk
#   boot: cdrom, floppy, disk
#=======================================================================
#boot: floppy
boot: disk

#=======================================================================
# LOG:
# Give the path of the log file you'd like Bochs debug and misc. verbiage
# to be written to. If you don't use this option or set the filename to
# '-' the output is written to the console. If you really don't want it,
# make it "/dev/null" (Unix) or "nul" (win32). :^(
#
# Examples:
#   log: ./bochs.out
#   log: /dev/tty
#=======================================================================
#log: /dev/null
log: bochsout.txt

#=======================================================================
# MOUSE:
# This defines parameters for the emulated mouse type, the initial status
# of the mouse capture and the runtime method to toggle it.
#
#  TYPE:
#  With the mouse type option you can select the type of mouse to emulate.
#  The default value is 'ps2'. The other choices are 'imps2' (wheel mouse
#  on PS/2), 'serial', 'serial_wheel' and 'serial_msys' (one com port requires
#  setting 'mode=mouse'). To connect a mouse to an USB port, see the 'usb_uhci',
#  'usb_ohci' or 'usb_xhci' options (requires PCI and USB support).
#
#  ENABLED:
#  The Bochs gui creates mouse "events" unless the 'enabled' option is
#  set to 0. The hardware emulation itself is not disabled by this.
#  Unless you have a particular reason for enabling the mouse by default,
#  it is recommended that you leave it off. You can also toggle the mouse
#  usage at runtime (RFB, SDL, Win32, wxWidgets and X11 - see below).
#
#  TOGGLE:
#  The default method to toggle the mouse capture at runtime is to press the
#  CTRL key and the middle mouse button ('ctrl+mbutton'). This option allows
#  to change the method to 'ctrl+f10' (like DOSBox), 'ctrl+alt' (like QEMU)
#  or 'f12' (replaces win32 'legacyF12' option).
#
# Examples:
#   mouse: enabled=1
#   mouse: type=imps2, enabled=1
#   mouse: type=serial, enabled=1
#   mouse: enabled=0, toggle=ctrl+f10
#=======================================================================
mouse: enabled=0

#=======================================================================
# KEYBOARD:
# This defines parameters related to the emulated keyboard
#
#   TYPE:
#     Type of keyboard return by a "identify keyboard" command to the
#     keyboard controller. It must be one of "xt", "at" or "mf".
#     Defaults to "mf". It should be ok for almost everybody. A known
#     exception is french macs, that do have a "at"-like keyboard.
#
#   SERIAL_DELAY:
#     Approximate time in microseconds that it takes one character to
#     be transferred from the keyboard to controller over the serial path.
#
#   PASTE_DELAY:
#     Approximate time in microseconds between attempts to paste
#     characters to the keyboard controller. This leaves time for the
#     guest os to deal with the flow of characters.  The ideal setting
#     depends on how your operating system processes characters.  The
#     default of 100000 usec (.1 seconds) was chosen because it works 
#     consistently in Windows.
#     If your OS is losing characters during a paste, increase the paste
#     delay until it stops losing characters.
#
#   KEYMAP:
#     This enables a remap of a physical localized keyboard to a
#     virtualized us keyboard, as the PC architecture expects.
#
# Examples:
#   keyboard: type=mf, serial_delay=200, paste_delay=100000
#   keyboard: keymap=gui/keymaps/x11-pc-de.map
#=======================================================================
#keyboard: type=mf, serial_delay=250

#=======================================================================
# ATA0, ATA1, ATA2, ATA3
# ATA controller for hard disks and cdroms
#
# ata[0-3]: enabled=[0|1], ioaddr1=addr, ioaddr2=addr, irq=number
# 
# These options enables up to 4 ata channels. For each channel
# the two base io addresses and the irq must be specified.
# 
# ata0 and ata1 are enabled by default with the values shown below
#
# Examples:
#   ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14
#   ata1: enabled=1, ioaddr1=0x170, ioaddr2=0x370, irq=15
#   ata2: enabled=1, ioaddr1=0x1e8, ioaddr2=0x3e0, irq=11
#   ata3: enabled=1, ioaddr1=0x168, ioaddr2=0x360, irq=9
#=======================================================================
ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14
ata1: enabled=1, ioaddr1=0x170, ioaddr2=0x370, irq=15
ata2: enabled=0, ioaddr1=0x1e8, ioaddr2=0x3e0, irq=11
ata3: enabled=0, ioaddr1=0x168, ioaddr2=0x360, irq=9

#=======================================================================
# GDBSTUB:
# Enable GDB stub. See user documentation for details.
# Default value is enabled=0.
#=======================================================================
#gdbstub: enabled=0, port=1234, text_base=0, data_base=0, bss_base=0
```

上面是从`bochsrc-sample.txt`中摘取的我们需要的配置与说明，大家看了说明就对配置项有了解了。

最终的配置如下：

```
# 设置虚拟机内存为32MB
megs: 32

# 设置BIOS镜像
romimage: file=$BXSHARE/BIOS-bochs-latest 

# 设置VGA BIOS镜像
vgaromimage: file=$BXSHARE/VGABIOS-lgpl-latest

# 设置从硬盘启动
boot: disk

# 设置日志文件
log: bochsout.txt

# 关闭鼠标
mouse: enabled=0

# 打开键盘
keyboard: type=mf, serial_delay=250

# 设置硬盘
ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14

# 添加gdb远程调试支持
gdbstub: enabled=1, port=1234, text_base=0, data_base=0, bss_base=0
```

保存配置文件为bochsrc.txt，然后在该目录下运行bochs命令：

```
➜  /Users/mazhibin/project/system/bochs-conf-file > bochs
========================================================================
                        Bochs x86 Emulator 2.6
            Built from SVN snapshot on September 2nd, 2012
                  Compiled on May  5 2018 at 23:07:30
========================================================================
00000000000i[     ] reading configuration from bochsrc.txt
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [6] 6       ←这里按回车，表示读取bochsrc.txt的配置，启动模拟器
00000000000i[     ] installing sdl module as the Bochs GUI
00000000000i[     ] using log file bochsout.txt
Next at t=0
(0) [0x00000000fffffff0] f000:fff0 (unk. ctxt): jmp far f000:e05b         ; ea5be000f0
<bochs:1> c       ←这里按c表示继续
========================================================================
Bochs is exiting with the following message:
[BIOS ] No bootable device.
========================================================================
(0).[13925235] [0x00000000000f054a] f000:054a (unk. ctxt): out dx, al                ; ee
```

bochs默认会在启动后暂停，我们按`c`，使bochs继续启动。最后bochs提示错误信息`[BIOS ] No bootable device.`并退出了虚拟机。

![](/img/os/bochs-fail-1.png)

这和我们物理机一样，在没有安装硬盘的情况下，启动后就会提示没有可以用于启动的设备。所以我们需要弄一个硬盘出来。

## 模拟硬盘

bochs作为一个模拟器，也提供了创建虚拟硬盘的工具bximage。这个工具提供了交互的方式来创建虚拟硬盘，我们来看看：

```
➜  /Users/mazhibin/project/system/bochs-conf-file > bximage
========================================================================
                                bximage
                  Disk Image Creation Tool for Bochs
          $Id: bximage.c 11315 2012-08-05 18:13:38Z vruppert $
========================================================================

Do you want to create a floppy disk image or a hard disk image?
Please type hd or fd. [hd]  ← 按回车，表示新建硬盘

What kind of image should I create?
Please type flat, sparse or growing. [flat] ← 按回车，表示新建flat形式的硬盘

Enter the hard disk size in megabytes, between 1 and 8257535
[10] ← 按回车，表示新建10MB的硬盘

I will create a 'flat' hard disk image with
  cyl=20
  heads=16
  sectors per track=63
  total sectors=20160
  total size=9.84 megabytes

What should I name the image?
[c.img] hd10m.img

Writing: [] Done.

I wrote 10321920 bytes to hd10m.img.

The following line should appear in your bochsrc:
  ata0-master: type=disk, path="hd10m.img", mode=flat, cylinders=20, heads=16, spt=63
```

最后bximage命令提示我们，需要在bochs的配置文件中添加一行配置`ata0-master: type=disk, path="hd10m.img", mode=flat, cylinders=20, heads=16, spt=63`。我们这这行添加到bochsrc.txt后再次启动bochs：

![](/img/os/bochs-fail-2.png)

最终的提示依然是`No bootable device`，但是仔细观察会发现，之前在没有配置硬盘是，详细的错误信息是`Boot failed: could not read the boot disk`，而再插入了空硬盘后，详细的错误信息是`Boot failed: not a bootable disk`。前者是说没有找到可以用于启动的硬盘，后者是说这个硬盘无法用来启动。

接下来就是如何在磁盘中写入启动信息，也就是主引导记录MBR了。后续的文章会继续学习。

## 参考资料
- [bochs: The Open Source IA-32 Emulation Project (Home Page)](http://bochs.sourceforge.net/)

Mac编译安装bochs的参考资料：
- [mac 安装 bochs - CSDN博客](https://blog.csdn.net/yzr1183739890/article/details/54864841)
- [macOS 编译安装 bochs 虚拟机 | nswebfrog](https://blog.nswebfrog.com/2017/02/03/config-bochs/)
- [Bochs x86 PC emulator download | SourceForge.net](https://sourceforge.net/projects/bochs/?source=typ_redirect)
- [Bochs x86 PC emulator / Patches / #537 Compilation failure in cdrom_osx.cc](https://sourceforge.net/p/bochs/patches/537/)

