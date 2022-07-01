//
//  Observable.swift
//  
//
//  Created by 谢鸿标 on 2022/7/1.
//

import Foundation

open class AnyObservable {
    
    private var observers = Set<AnyObserverContainer>()
    
    deinit {
        #if DEBUG
        print("self = \(self) released")
        #endif
    }
    
    public init() {}
    
    open func add(observer: AnyObserverContainer) {
        observers.insert(observer)
    }
    
    public func notifyAll<Value>(_ value: Value) {
        if observers.isEmpty { return }
        observers.forEach { [weak self] observerContainer in
            self?.notify(value: value, to: observerContainer)
        }
        observers = observers.filter { !$0.observerIsNil() }
    }
    
    public func notify<Value>(value: Value, to target: AnyObserverContainer) {
        target.notify(value: value)
    }
}

final public class Observable<Value>: AnyObservable {

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
    
    public override func notify<Value>(value: Value, to target: AnyObserverContainer) {
        if let queue = queue {
            queue.async {
                super.notify(value: value, to: target)
            }
        } else {
            super.notify(value: value, to: target)
        }
    }
}

extension Observable {
    
    public func add<Observer: AnyObject>(observer: Observer, closure: @escaping ObserverClosure<Observer, Value>) {
        let newOne = ObserverContainer<Observer>(observer, closure)
        add(observer: newOne)
    }
}

extension Observable {
    
    public func add<Observer: AnyObject>(observer: Observer,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value>) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject>(observer: Observer,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value?>) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T>,
                                            convert: @escaping (Value) -> T) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = convert(value)
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T?>,
                                            convert: @escaping (Value) -> T?) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = convert(value)
        }
    }
}
