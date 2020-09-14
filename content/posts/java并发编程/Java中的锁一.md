---
title: Java中的锁（Lock接口）
date: 2019-07-09 19:39:01
tags:
- Java
- 并发
- 多线程
categories:
- Java并发编程
---

锁是用来控制多个线程访问共享资源的方式，一般来说，一个锁能够防止多个线程同时访问共享资源（但是有些锁可以允许多个线程并发的访问共享资源，如：读写锁）。

在Lock接口出现之前，Java程序依靠 **synchronized** 关键字实现锁的功能。

**Java1.5**之后，并发包中新增了 **Lock** 接口（以及相关实现类）用来实现锁功能，它提供了与 synchronized 关键字类似的同步功能，只是使用时需要显示地获取和释放锁。

<!-- more -->

## Lock接口优缺点对比：

**优点**：拥有**锁获取**与**释放锁**的**可操作性**、**可中断的获取锁**以及**超时获取锁**等多种synchronized关键字所不具备的同步特性。

**缺点**：缺少了（通过synchronized块或方法锁提供的）隐式获取、释放锁的**便捷性**。

synchronized 关键字会隐式地获取锁，但是它将锁的获取和释放固化了，也就是**先获取再释放**，但同时，这种方式简化了同步的管理。

---

## Lock的使用

```java
Lock lock = new ReentranLock();
lock.lock();
try {
} finally {
    lock.unlock();
}
```

在finally块中释放锁，目的是保证在获取到锁之后，最终能被释放。

**注意**：不要将获取锁的过程卸载try块中，因为如果在获取锁（自定义实现）时发生了异常，异常抛出的同时，也会导致锁无故释放。

---

## Lock接口API

```java
// 获取锁，调用该方法当前线程将会获取锁，当锁获得后，从该方法返回。
void lock();

// 可中断地获取锁，和 lock() 方法的不同之处在于该方法会响应中断，即在锁的获取中可以中断当前线程。
void lockInterruptibly() throws InterruptedException;

// 尝试非阻塞的获取锁，调用该方法后立刻返回，如果能够获取则返回 true，否则返回 false。
boolean tryLock();

/**
 * 超时的获取锁，当前线程在以下3种情况下会返回：
 * 1. 当前线程在超时时间内获得了锁。
 * 2. 当前线程在超时时间内被中断。
 * 3. 超时时间结束，返回 false。
 */
boolean tryLock(long time, TimeUnit unit) throws InterruptedException;

// 释放锁。
void unlock();

// 获取等待通知组件，该组件和当前的锁绑定，
// 当前线程只有获得了锁，才能调用该组件的 wait() 方法，
// 而调用后，当前线程将被释放锁。
Condition newCondition();
```


