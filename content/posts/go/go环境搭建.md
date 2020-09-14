---
title: Go环境搭建
date: 2019-10-16 15:00:00
tags:
- Go
categories:
- 环境搭建
---

## Go开发环境

### 下载并安装Go开发包

Go语言开发包：[https://golang.org/](https://golang.org/)

<!-- more -->

### 安装并配置环境变量

```
# go语言安装路径
GOROOT=C:\Go\

# 修改gopath路径
GOPATH=D:\gopath\

# gopath目录结构
|- gopath
  |- bin
  |- pkg
  |- src
    |- github.com
      |- cuilan
        |- go-demo
      |- xxx
    |- gitee.com
```

## 安装 VSCode

### 下载并安装 VSCode

### 安装 ms-vscode.go 插件

安装 Go 插件：搜索：**Go**，安装：`ms-vscode.go` 插件。

### 安装 go-tools

```
cd %GOPATH%\src\

go get -u -v golang.org/x/tools/cmd/godoc
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v github.com/nsf/gocode
go get -u -v github.com/golang/lint/golint
go get -u -v github.com/lukehoban/go-outline
go get -u -v github.com/rogpeppe/godef
go get -u -v github.com/sqs/goreturns
go get -u -v github.com/tpng/gopkgs
go get -u -v github.com/newhook/go-symbols
go get -u -v github.com/derekparker/delve/cmd/dlv
go get -u -v github.com/josharian/impl
go get -u -v github.com/cweill/gotests/gotests
go get -u -v github.com/lukehoban/go-find-references
go get -u -v github.com/fatih/gomodifytags
go get -u -v github.com/haya14busa/goplay/cmd/goplay

```



