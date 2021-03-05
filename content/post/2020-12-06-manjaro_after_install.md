---
layout:     post 
title:      "manjaro安装后基本配置"
subtitle:   ""
description: "manjaro安装后基本配置。"
date:       2020-12-06
author:     "张岩"
published: true
tags:
    - Linux
    - manjaro
categories: [ Linux ]
---

# 设置官方镜像源（包括 core, extra, community, mutilab）

```bash
// 更新镜像排名
$ sudo pacman-mirrors -i -c China -m rank

然后勾选需要的镜像源，确认即可。

// 更新数据源
$ sudo pacman -Syy

// 更新系统软件
$ sudo pacman -Syu
```

---

# 安装常用软件

## 安装中文输入法

### 编辑配置文件

```bash
$ sudo vim /etc/pacman.conf
```

在文件最后添加：

```conf
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = http://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

### 更新并安装秘钥

```bash
$ sudo pacman -Syy
$ sudo pacman -S archlinuxcn-keyring
```

### 安装fcitx-im中文输入法框架

```bash
$ sudo pacman -S fcitx-im

```

### 安装配置窗口

```bash
$ sudo pacman -S fcitx-configtool
```

### 安装google拼音输入法

```bash
$ sudo pacman -S fcitx-googlepinyin
```

### 配置

```bash
vi ~/.xprofile

export GTK_IM_MODULE=fctix
export QT_IM_MODULE=fctix
export XMODIFIERS="@im=fctix"
```

