---
title: Java并发机制的底层实现原理（volatile）
date: 2019-03-05 23:20:27
tags:
- Java
- 并发
- 多线程
categories:
- Java并发编程
---

Java中所使用的并发机制依赖于JVM的实现和CPU的指令。在多线程并发编程中 **synchronized** 和 **volatile** 都扮演着重要的角色。

## volatile的应用

**volatile** 是轻量级的 **synchronized**，它在多处理器开发中保证了共享变量的“**可见性**”。**可见性的意思是当一个线程修改一个共享变量时，另外一个线程能读到这个修改的值。** 如果volatile变量修饰符使用适当的话，它比synchronized的使用和执行成本更低，因为它不会引起线程上下文的切换和调度。

<!-- more -->

## volatile的定义与实现原理

### 定义：
Java编程语言允许线程访问共享变量，为了确保贡献变量能被准确和一致地更新，线程应该确保通过排他锁单独获得这个变量。
如果一个字段被声明成volatile，Java线程内存模型确保所有线程看到这个变量的值是一致的。

### volatile的使用场景

**1.防止重排序**

如在并发环境下的单例模式中，可以使用 **volatile** 关键字来防止编译时的指令重排。

```java
public class Singleton {
    public static volatile Singleton singleton;
	
    /**
     * 私有化构造函数，防止外部调用实例化
     */
    private Singleton() {
    }
	
    public static Singleton getInstance() {
        if (singleton == null) {
            synchronized (singleton) {
                if (singleton == null) {
                    singleton = new Singleton();
                }
            }
        }
        return singleton;
    }
}
```

JVM实例化一个对象的过程分为三个步骤：
- 分配内存空间
- 初始化对象
- 将内存空间的地址赋值给对象的引用

但由于指令的重排，在多线程的场景下，可能会先将内存空间的地址值赋值给对象的引用，然后才实例化对象。这种情况会将一个未实例化的对象引用暴露出去，因此成员变量singleton被volatile关键字修饰，并在实例化时进行双重检查加锁（Double-Checked Lock）来保证单例对象的唯一性。

**2.实现内存可见性**
**3.保证原子性**

* * *

### volatile原理：

**1. 内存可见性的实现**

每个线程本身不直接与内存进行数据交互，而是通过线程本身的工作内存（CPU内部缓存L1、L2、L3）完成操作，这也是导致线程间数据不可见的原因。因此要实现volatile变量的可见性，也是通过这一特性来实现。对volatile变量的操作与普通变量操作的主要区别有两点：
 - 修改volatile变量时会强制将修改后的值刷新到主内存中。
 - 修改volatile变量后会导致其他线程工作内存中对应的变量值失效。因此，再读取该变量值的时候就需要重新从主内存中读取值。

**2. 有序性实现**

有序性通过 Java 中的 happen-before 的规则，如果 a happen-before b，则a所做的任何操作对b是可见的。

**3. 内存屏障**

JVM底层是通过一个叫做“内存屏障”的东西来完成。内存屏障，也叫做内存栅栏，是一组处理器指令，用于实现对内存操作的顺序限制。

* * *
