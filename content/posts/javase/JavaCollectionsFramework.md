---
title: Java集合框架源码分析
date: 2019-07-12T16:31:00+08:00
tags:
- Java
- 源码
- 集合框架
- 目录
categories:
- JavaSE
---

## 接口
<font style="font-size:18px;">
**单列集合接口**
<a href="/blog/2019/07/12/javase/Iterable-source-analysis/">java.lang.Iterable</a>&lt;Interface&gt;
&emsp;<a href="/blog/2019/07/15/javase/Collection-source-analysis/">java.util.Collection</a>&lt;Interface&gt;
&emsp;&emsp;<a href="/blog/2019/07/17/javase/List-source-analysis/">java.util.List</a>&lt;Interface&gt;
&emsp;&emsp;<a href="/blog/2019/07/18/javase/Set-source-analysis/">java.util.Set</a>&lt;Interface&gt;
&emsp;&emsp;&emsp;<a href="/blog/2019/07/30/javase/SortedSet-source-analysis/">java.util.SortedSet</a>&lt;Interface&gt;
&emsp;&emsp;&emsp;&emsp;<a href="/blog/2019/08/01/javase/NavigableSet-source-analysis/">java.util.NavigableSet</a>&lt;Interface&gt;
&emsp;&emsp;<a href="/blog/2019/08/05/javase/Queue-source-analysis/">java.util.Queue</a>&lt;Interface&gt;
&emsp;&emsp;&emsp;<a href="/blog/2019/08/06/javase/Deque-source-analysis/">java.util.Deque</a>&lt;Interface&gt;

**双列集合接口**
<a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>&lt;Interface&gt;
&emsp;<a href="/blog/2019/08/27/javase/SortedMap-source-analysis/">java.util.SortedMap</a>&lt;Interface&gt;
&emsp;&emsp;<a href="/blog/2019/08/28/javase/NavigableMap-source-analysis/">java.util.NavigableMap</a>&lt;Interface&gt;

</font>

---

## 抽象类/类，继承关系，实现接口
<font style="font-size:18px;">
**单列集合类**
<a href="/blog/2019/07/18/javase/AbstractCollection-source-analysis/">java.util.AbstractCollection</a>&lt;Abstract&gt; ------------------------- <a href="/blog/2019/07/15/javase/Collection-source-analysis/">java.util.Collection</a>
&emsp;<a href="/blog/2019/07/24/javase/AbstractList-source-analysis/">java.util.AbstractList</a>&lt;Abstract&gt; ------------------------------- <a href="/blog/2019/07/17/javase/List-source-analysis/">java.util.List</a>
&emsp;&emsp;<a href="/blog/2018/11/15/javase/array-list-source-analysis/">java.util.ArrayList</a>&lt;Class&gt; ------------------------------------ <a href="/blog/2019/07/17/javase/List-source-analysis/">java.util.List</a>, java.util.RandomAccess
&emsp;&emsp;<a href="/blog/2019/08/09/javase/AbstractSequentialList-source-analysis/">java.util.AbstractSequentialList</a>&lt;Abstract&gt;
&emsp;&emsp;&emsp;<a href="/blog/2018/12/06/javase/linked-list-source-analysis/">java.util.LinkedList</a>&lt;Class&gt; ------------------------------- <a href="/blog/2019/07/17/javase/List-source-analysis/">java.util.List</a>, <a href="/blog/2019/08/06/javase/Deque-source-analysis/">java.util.Deque</a>
&emsp;&emsp;<a href="">java.util.Vector</a>&lt;Class&gt; --------------------------------------- <a href="/blog/2019/07/17/javase/List-source-analysis/">java.util.List</a>, java.util.RandomAccess
&emsp;&emsp;&emsp;<a href="">java.util.Stack</a>&lt;Class&gt;
&emsp;<a href="/blog/2019/08/16/javase/AbstractSet-source-analysis/">java.util.AbstractSet</a>&lt;Abstract&gt; ------------------------------- <a href="/blog/2019/07/18/javase/Set-source-analysis/">java.util.Set</a>
&emsp;&emsp;<a href="/blog/2019/08/19/javase/HashSet-source-analysis/">java.util.HashSet</a>&lt;Class&gt; ------------------------------------- <a href="/blog/2019/07/18/javase/Set-source-analysis/">java.util.Set</a>
&emsp;&emsp;&emsp;<a href="/blog/2019/08/19/javase/LinkedHashSet-source-analysis/">java.util.LinkedHashSet</a>&lt;Class&gt; ------------------------- <a href="/blog/2019/07/18/javase/Set-source-analysis/">java.util.Set</a>
&emsp;&emsp;<a href="/blog/2019/08/20/javase/TreeSet-source-analysis/">java.util.TreeSet</a>&lt;Class&gt; -------------------------------------- <a href="/blog/2019/08/01/javase/NavigableSet-source-analysis/">java.util.NavigableSet</a>
&emsp;<a href="/blog/2019/08/21/javase/AbstractQueue-source-analysis/">java.util.AbstractQueue</a>&lt;Abstract&gt; -------------------------- <a href="/blog/2019/08/05/javase/Queue-source-analysis/">java.util.Queue</a>
&emsp;<a href="">java.util.ArrayDeque</a>&lt;Class&gt; ---------------------------------- <a href="/blog/2019/08/06/javase/Deque-source-analysis/">java.util.Deque</a>

**双列集合类**
<a href="/blog/2019/09/02/javase/AbstractMap-source-analysis/">java.util.AbstractMap</a>&lt;Abstract&gt; -------------------------------- <a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>
&emsp;<a href="/blog/2019/09/03/javase/HashMap-source-analysis/">java.util.HashMap</a>&lt;Class&gt; ------------------------------------- <a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>
&emsp;&emsp;<a href="/blog/2019/09/15/javase/LinkedHashMap-source-analysis/">java.util.LinkedHashMap</a>&lt;Class&gt; ------------------------- <a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>
&emsp;<a href="/blog/2019/09/17/javase/TreeMap-source-analysis/">java.util.TreeMap</a>&lt;Class&gt; --------------------------------------- <a href="/blog/2019/08/28/javase/NavigableMap-source-analysis/">java.util.NavigableMap</a>
&emsp;<a href="">java.util.WeakHashMap</a>&lt;Class&gt; ------------------------------ <a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>
<a href="/blog/2019/09/17/javase/Dictionary-source-analysis/">java.util.Dictionary</a>&lt;Abstract&gt; 已过时
&emsp;<a href="">java.util.Hashtable</a>&lt;Class&gt; 已过时 --------------------------- <a href="/blog/2019/08/21/javase/Map-source-analysis/">java.util.Map</a>



</font>