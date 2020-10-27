---
layout:     post 
title:      "三、Explain插叙优化器"
subtitle:   "Explain插叙优化器，Explain关键字，查询优化原理分析"
date:       2020-10-26
tags:
- 中间件
- MySQL
categories:
- 中间件
---

> 对于一个 SQL 语句，查询优化器先看是不是能转换成 JOIN ，再将 JOIN 进行优化。
>
> 优化分为：
>
> 1. 条件优化
> 2. 计算全表扫描成本
> 3. 找出所有能用到的索引
> 4. 针对每个索引计算不同的访问方式的成本
> 5. 选出成本最小的索引以及访问方式

# 开启查询优化器日志

```mysql
-- 开启
SET optimizer_trace="enable=on";

-- 执行sql
SELECT * FROM table...;

-- 查看日志信息
SELECT * FROM information_schema.OPTIMIZER_TRACE;

-- 关闭
SET optimizer_trace="enable=off";
```















































