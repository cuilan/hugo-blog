---
title: Hexo常用命令
date: 2018-11-06T16:35:23+08:00
tags: ["Hexo"]
categories: ["环境搭建"]
---

创建任意目录

开始安装：
```bash
npm install hexo --save
```

<!-- more -->

检测安装是否成功：
```bash
hexo -v
```

初始化：
```bash
hexo init
```

安装所需组件：
```bash
npm install
```

创建文件： layout 可省略，默认使用 _config.yml 中的 default_layout 参数代替
```bash
hexo new [layout] <title>
hexo n "filename"
```

生成静态页面：
```bash
hexo generate
hexo g
```

开启服务：
```bash
hexo server
hexo s
```

安装本地图片上传插件：
```bash
npm install hexo-asset-image --save
```