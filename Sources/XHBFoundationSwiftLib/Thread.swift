//
//  Thread.swift
//  
//
//  Created by xiehongbiao on 2022/6/30.
//

import Foundation

public func synchronized<Object, Value>(_ locked: Object,
                                        _ action: () -> Value) -> Value {
    objc_sync_enter(locked)
    let result = action()
    objc_sync_exit(locked)
    return result
}

public protocol Lockable: AnyObject {
    
    func lock()
    func unlock()
}

///系统自旋锁
@available(iOS 10.0, OSX 10.12, watchOS 3.0, tvOS 10.0, *)
public final class OSUnfairLock: Lockable {
    
    private var _lock = os_unfair_lock_s()
    
    public func lock() {
        os_unfair_lock_lock(&_lock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}

///互斥锁
public final class MutexLock: Lockable {
    
    private var _lock = pthread_mutex_t()
    
    public init() {
        pthread_mutex_init(&_lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&_lock)
    }
    
    public func lock() {
        pthread_mutex_lock(&_lock)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&_lock)
    }
}

///递归锁
public final class RecursiveLock: Lockable {
    
    private var _lock = pthread_mutex_t()
    
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&_lock, &attr)
    }
    
    deinit {
        pthread_mutex_destroy(&_lock)
    }
    
    public func lock() {
        pthread_mutex_lock(&_lock)
    }

    public func unlock() {
        pthread_mutex_unlock(&_lock)
    }
}

///条件锁
public final class ConditionLock: Lockable {
    
    private var _lock1 = pthread_cond_t()
    private var _lock2 = pthread_mutex_t()
    
    public init() {
        pthread_cond_init(&_lock1, nil)
        pthread_mutex_init(&_lock2, nil)
    }
    
    deinit {
        pthread_cond_destroy(&_lock1)
        pthread_mutex_destroy(&_lock2)
    }
    
    public func lock() {
        pthread_mutex_lock(&_lock2)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&_lock2)
    }
    
    public func wait(until time: TimeInterval) {
        let integerPart = Int(time.nextDown)
        let fractionPart = time - TimeInterval(integerPart)
        var pthread_time = timespec(tv_sec: integerPart, tv_nsec: Int(fractionPart * 1000000000))
        pthread_cond_timedwait_relative_np(&_lock1, &_lock2, &pthread_time)
    }
    
    public func wait() {
        pthread_cond_wait(&_lock1, &_lock2)
    }
    
    public func signal() {
        pthread_cond_signal(&_lock1)
    }
}

///自旋锁实现
public final class SpinLock: Lockable {
    
    private let _lock: Lockable
    
    public init() {
        if #available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *) {
            _lock = OSUnfairLock()
        } else {
            _lock = MutexLock()
        }
    }

    public func lock() {
        _lock.lock()
    }
    
    public func unlock() {
        _lock.unlock()
    }
}

extension DispatchQueue {
    
    public static let spin = SpinLock()
    public static var pool = Set<String>()
    
    ///GCD实现一次执行
    public static func once(name: String, _ block: () -> Void) {
        spin.lock(); defer { spin.unlock() }
        guard !pool.contains(name) else { return }
        block()
        pool.insert(name)
    }
}

///自旋锁实现值原子性
@propertyWrapper
public final class Atomic<Value> {
    
    private let spin = SpinLock()
    private var value: Value
    
    public var wrappedValue: Value {
        set {
            spin.lock(); defer { spin.unlock() }
            value = newValue
        }
        get {
            spin.lock(); defer { spin.unlock() }
            return value
        }
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public func withValue(_ closure: (Value) -> Value) {
        spin.lock(); defer { spin.unlock() }
        value = closure(value)
    }
}

extension Atomic: CustomStringConvertible {
    
    public var description: String { "\(wrappedValue)" }
}

extension Atomic where Value == Int {
    
    public static func += (lhs: Atomic, rhs: Value) {
        lhs.withValue { $0 + rhs }
    }
    
    public static func -= (lhs: Atomic, rhs: Value) {
        lhs.withValue { $0 - rhs }
    }
}

extension Atomic where Value: Equatable {
    
    public static func == (lhs: Atomic, rhs: Value) -> Bool {
        return lhs.wrappedValue == rhs
    }
    
    public static func == (lhs: Atomic, rhs: Atomic) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}
