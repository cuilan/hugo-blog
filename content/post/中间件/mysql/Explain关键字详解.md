---
layout:     post 
title:      "六、Explain关键字详解"
subtitle:   "Explain关键字"
date:       2020-11-02
tags:
- 中间件
- MySQL
categories:
- 中间件
---

# Explain关键字

| 列名 | 描述 |
| :--- | :--- |
| id | 在一个大的查询语句中每个SELECT关键字都对应一个唯一的id |
| select_type | SELECT关键字对应的那个查询的类型 |
| table | 表名 |
| partitions | 匹配的分区信息 |
| **type** | 针对单表的访问方法 |
| **possible_keys** | 可能用到的索引 |
| **key** | 实际使用的索引 |
| **key_len** | 实际使用的索引长度 |
| ref | 当使用索引列等值查询时，与索引列进行等值匹配的对象信息 |
| rows | 预估的需要读取的记录条数 |
| filtered | 某个表经过搜索条件过滤后剩余记录条数的百分比 |
| **Extra** | 一些额外的信息 |

---

# 各字段详解































