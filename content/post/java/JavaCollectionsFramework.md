---
title: Java集合框架源码分析
date: 2019-07-12T16:31:00+08:00
tags:
- Java
- 源码
- 集合框架
- 目录
categories:
- JAVA
- 目录
---

# 一、接口

## 单列集合接口

* [java.lang.Iterable](/post/java/iterable-source-analysis/)
  * [java.util.Collection](/post/java/collection-source-analysis/)
    * [java.util.List](/post/java/list-source-analysis/)
    * [java.util.Set](/post/java/set-source-analysis/)
      * [java.util.SortedSet](/post/java/sortedset-source-analysis/)
        * [java.util.NavigableSet](/post/java/navigableset-source-analysis/)
    * [java.util.Queue](/post/java/queue-source-analysis/)
      * [java.util.Deque](/post/java/deque-source-analysis/)

## 双列集合接口

* [java.util.Map](/post/java/map-source-analysis/)
  * [java.util.SortedMap](/post/java/sortedmap-source-analysis/)
    * [java.util.NavigableMap](/post/java/navigablemap-source-analysis/)

---

# 二、抽象类/类，继承关系，实现接口

## 单列集合类

* [java.util.AbstractCollection](/post/java/abstractcollection-source-analysis/)
  * [java.util.AbstractList](/post/java/abstractlist-source-analysis/)
    * [java.util.ArrayList](/post/java/array-list-source-analysis/)
    * [java.util.AbstractSequentialList](/post/java/abstractsequentiallist-source-analysis/)
      * [java.util.LinkedList](/post/java/linked-list-source-analysis/)
    * [java.util.Vector]()
      * [java.util.Stack]()
  * [java.util.AbstractSet](/post/java/abstractset-source-analysis/)
    * [java.util.HashSet](/post/java/hashset-source-analysis/)
      * [java.util.LinkedHashSet](/post/java/linkedhashset-source-analysis/)
    * [java.util.TreeSet](/post/java/treeset-source-analysis/)
  * [java.util.AbstractQueue](/post/java/abstractqueue-source-analysis/)
  * [java.util.ArrayDeque]()

## 双列集合类

* [java.util.AbstractMap](/post/java/abstractmap-source-analysis/)
  * [java.util.HashMap](/post/java/hashmap-source-analysis/)
    * [java.util.LinkedHashMap](/post/java/linkedhashmap-source-analysis/)
  * [java.util.TreeMap](/post/java/treemap-source-analysis/)
  * [java.util.WeakHashMap]()
* [java.util.Dictionary](/post/java/dictionary-source-analysis/) 已过时
  * [java.util.Hashtable]() 已过时
