---
title: Java中的锁-AbstractQueuedSynchronizer队列同步器
date: 2019-09-19 12:00:00
tags:
- Java
- 并发
- 多线程
categories:
- 并发编程
---

**AbstractQueuedSynchronizer** 同步器提供了一个框架，用于构建 **先进先出(FIFO)** 等待队列的 **阻塞锁** 和 **相关同步器（信号量，事件等）**。它使用了一个 **int** 成员变量表示同步状态，通过 FIFO 队列来完成资源获取线程的排队工作。

## 一、同步器的使用

- 同步器的主要使用方式是 **继承**，子类通过继承同步器并实现它的抽象方法来管理同步状态。
- 使用同步器提供的3个方法：**`getState()`**，**`setState(int newState)`** 和 **`compareAndSetState(int expect, int update)`** 进行操作，因为以上方法可以保证状态的改变是安全的。
- 子类应定义为非公共的静态内部类。

<!-- more -->

### 访问或修改同步状态的3个方法

源码中这三个方法都被定义为 **`final`**，子类不可以重写。

- **`getState()`**：获取当前同步状态。
- **`setState(int newState)`**：设置当前同步状态。
- **`compareAndSetState(int expect, int update)`**：使用 CAS 设置当前状态，该方法能保证状态设置的原子性。

---

## 二、独占模式和共享模式

**AbstractQueuedSynchronizer** 支持 **独占模式（默认）** 和 **共享模式** 两种。

- 独占模式下，当一个线程获取到锁，其他线程只能处于同步队列中等待，只有获取到锁的线程释放了锁，其他线程才能获取锁。
- 共享模式下，多个线程可以同时获取锁，并发的访问资源，如：**`ReadWriteLock`**。

通常，子类实现仅支持其中的一种模式，但在 **`ReadWriteLock`** 读写锁中两种模式都可以发挥作用。

### 2.1 同步器可重写的方法

仅支持独占模式的子类无需重写：**`tryAcquireShared()`**、**`tryReleaseShared()`** 方法。
仅支持共享模式的子类无需重写：**`tryAcquire()`**、**`tryRelease()`** 方法。

| 方法名称 | 功能描述 |
| --- | --- |
| **`boolean tryAcquire(int arg)`** | 独占式获取同步状态，实现该方法需要查询当前状态并判断同步状态十分符合预期，然后进行CAS设置同步状态。 |
| **`boolean tryRelease(int arg)`** | 独占式释放同步状态，等待获取同步状态的线程将有机会获取同步状态。 |
| **`int tryAcquireShared(int arg)`** | 共享式获取同步状态，返回大于等于0的值，表示获取成功，反之，获取失败。 |
| **`boolean tryReleaseShared(int arg)`** | 共享式释放同步状态。 |
| **`boolean isHeldExclusively()`** | 当前同步器是否在独占模式下被线程占用，一般该方法表示是否被当前线程所占有。 |

### 2.2 独占锁示例

Mutex 独占锁，自定义同步组件，在同一时刻只允许一个线程占有锁。Mutex 中定义了一个静态内部类，该内部类继承了队列同步器，并实现了 **独占式获取和释放同步状态**。state 状态设置为 1 表示线程获取了锁，设置为 0 表示线程释放了锁。

```java
/**
 * 独占锁，自定义同步组件，在同一时刻只允许一个线程占有锁。
 *
 * @author zhang.yan
 * @date 2019/09/19
 */
public class Mutex implements Lock, java.io.Serializable {
    // 静态内部类，自定义同步器
    private class Sync extends AbstractQueuedSynchronizer {

        // 是否处于独占状态
        protected boolean isHeldExclusively() { return getState() == 1; }

        // 当状态为0时获取锁
        protected boolean tryAcquire(int acquires) {
            assert acquires == 1;
            if (compareAndSetState(0, 1)) {
                setExclusiveOwnerThread(Thread.currentThread());
                return true;
            }
            return false;
        }

        // 释放锁，将状态设置为0
        protected boolean tryRelease(int acquires) {
            assert acquires == 1;
            if (getState() == 0) { throw new IllegalMonitorStateException(); }
            setExclusiveOwnerThread(null);
            setState(0);
            return true;
        }

        // 返回一个Condition，每个condition都包含了一个condition队列
        Condition newCondition() { return new ConditionObject(); }
    }

    // 仅需要将操作代理到 Sync 上即可
    private final Sync sync = new Sync();

    public void lock() { sync.acquire(1); }
    public void lockInterruptibly() throws InterruptedException {
        sync.acquireInterruptibly(1);
    }
    public boolean tryLock() { return sync.tryAcquire(1); }
    public void unlock() { sync.release(1); }
    public Condition newCondition() { return sync.newCondition(); }
    public boolean isLocked() { return sync.isHeldExclusively(); }
    public boolean hasQueueThreads() { return sync.hasQueuedThreads(); }
    public boolean tryLock(long timeout, TimeUnit unit) throws InterruptedException {
        return sync.tryAcquireNanos(1, unit.toNanos(timeout));
    }
}
```
