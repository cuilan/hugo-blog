---
title: Java内存模型四（volatile内存语义）
date: 2019-05-30 23:35:00
tags:
- Java
- 并发
- 多线程
categories:
- Java并发编程
---

## 1、volatile的特性

 * **可见性**：对一个 volatile 变量的读，总是能看到（任意线程）对这个 volatile 变量最后的写入。
 * **原子性**：对任意单个 volatile 变量的读/写具有原子性，但类似于 volatile++ 这种复合操作不具有原子性。

## 2、volatile写-读建立的happens-before关系

从 JSR-133 开始（JDK5），volatile 变量的写-读可以实现线程之间的通信。

**从内存语义的角度来说，volatile 的读-写与锁的释放-获取有相同的内存效果**：_volatile 写和锁的释放有相同的内存语义_；_volatile 读和锁的获取有相同的内存语义_。

<!-- more -->

volatile 变量示例：

```java
class VolatileExample {
    private int a = 0;
    private volatile boolean flag = false;
    
    public void writer() {
        a = 1;          // 1
        flag = true;    // 2
    }
    
    public void reader() {
        if (flag) {     // 3
            int i = a;  // 4
        }
    }
}
```

根据 happens-before 规则：
 * 1、根据程序次序规则：1 happens-before 2; 3 happens-before 4
 * 2、根据 volatile 规则：2 happens-before 3
 * 3、根据 happens-before 的传递性规则：1 happens-before 4

## 3、volatile写-读的内存语义

volatile 写的内存语义：**当写一个 volatile 变量时，JMM 会把该线程对应的本地内存中的共享变量值刷新到主内存。**
volatile 读的内存语义：**当读一个 volatile 变量时，JMM 会吧该线程对应的本地内存置为无效。线程接下来将从主内存中读取共享变量。**

总结：

 * 线程 A 写一个 volatile 变量，实质上是线程 A 向接下来将要读这个 volatile 变量的某个线程发出了（其对共享变量所做修改的）消息。
 * 线程 B 读一个 volatile 变量，实质上是线程 B 接受了之前某个线程发出的（在写这个 volatile 变量之前对共享变量所做修改的）消息。
 * 线程 A 写一个 volatile 变量，随后线程 B 读这个 volatile 变量，这个过程实质上是线程 A 通过主内存想线程 B 发送消息。

## 4、volatile内存语义的实现

JMM 针对编译器制定的 volatile 重排序规则表：

| 是否能重排序 | 普通读/写 | volatile 读 | volatile 写 | 
| ------ | ------ | ------ | ------ |
| 普通读/写 |  |  | NO |
| volatile 读 | NO | NO | NO |
| volatile 写 |  | NO | NO |

文字描述：

 * **当第二个操作是 volatile 写时，不管第一个操作是什么，都不能重排序。这个规则确保 volatile 写之前的操作不会被编译器重排序到 volatile 写之后。**
 * **当第一个操作是 volatile 读时，不管第二个操作是什么，都不能重排序。这个规则确保 volatile 读之后的操作不会被编译器重排序到 volatile 读之后。**
 * **当第一个操作是 volatile 写，第二个操作是 volatile 读时，不能重排序。**

基于保守策略的JMM内存屏障插入策略：

 * _在每个 volatile 写操作的前面插入一个 StoreStore 屏障。_
 * _在每个 volatile 写操作的后面插入一个 StoreLoad 屏障。_
 * _在每个 volatile 读操作的前面插入一个 LoadLoad 屏障。_
 * _在每个 volatile 读操作的后面插入一个 LoadStore 屏障。_

## 5、JSR-133增强volatile的原因

在旧的内存模型中，volatile 的写-读没有锁的释放-获取所具有的的内存语义。

由于 volatile 仅仅保证对单个 volatile 变量的读-写具有原子性，而锁的互斥执行的特性可以确保对整个临界区代码的执行具有原子性。

**在功能上，锁比 volatile 更强大；在可伸缩性和执行性能上，volatile 更有优势。**
