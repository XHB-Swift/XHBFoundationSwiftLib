//
//  ValueObservable.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

final public class ValueObservable<Value>: AnyObservable {

    private var queue: DispatchQueue? = nil
    private let lock = DispatchSemaphore(value: 1)
    private var storedValue: Value
    
    public var observedValue: Value {
        set {
            lock.wait()
            storedValue = newValue
            notifyAll(storedValue)
            lock.signal()
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return storedValue
        }
    }

    public init(observedValue: Value,
                queue: DispatchQueue? = nil) {
        self.storedValue = observedValue
        self.queue = queue
    }
    
    public override func notify<Value>(value: Value, to target: AnyObserver) {
        if let queue = queue {
            queue.async {
                super.notify(value: value, to: target)
            }
        } else {
            super.notify(value: value, to: target)
        }
    }
}

extension ValueObservable {
    
    public func add<Observer: AnyObject>(observer: Observer?, closure: @escaping ObserverClosure<Observer, Value>) {
        let newOne = SpecifiedObserver<Observer>(observer, closure)
        add(observer: newOne)
    }
    
    public func add<Observer: AnyObject>(observer: Observer?,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value>) {
        add(observer: observer) { ob, value in
            ob[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject>(observer: Observer?,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value?>) {
        add(observer: observer) { ob, value in
            ob[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer?,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T>,
                                            convert: @escaping (Value) -> T) {
        add(observer: observer) { ob, value in
            ob[keyPath: keyPath] = convert(value)
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer?,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T?>,
                                            convert: @escaping (Value) -> T?) {
        add(observer: observer) { ob, value in
            ob[keyPath: keyPath] = convert(value)
        }
    }
}
