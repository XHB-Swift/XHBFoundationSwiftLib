//
//  AnyObservable.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class AnyObservable {
    
    private var observers = Set<AnyObserver>()
    
    deinit {
        #if DEBUG
        print("self = \(self) released")
        #endif
    }
    
    public init() {}
    
    open func add(observer: AnyObserver) {
        observers.insert(observer)
    }
    
    open func remove(observer: AnyObserver) {
        observers = observers.filter { $0 != observer }
    }
    
    open func remove(observer: AnyObject?) {
        guard let validateOb = observer else { return }
        observers = observers.filter {
            guard let validateRefOb = $0.base else { return false }
            let ob1 = ObjectIdentifier(validateRefOb)
            let ob2 = ObjectIdentifier(validateOb)
            return ob1 != ob2
        }
    }
    
    open func removeAllObservers() {
        observers.removeAll()
    }
    
    public func notifyAll<Value>(_ value: Value) {
        if observers.isEmpty { return }
        observers.forEach { [weak self] observerContainer in
            self?.notify(value: value, to: observerContainer)
        }
        observers = observers.filter { !$0.observerIsNil() }
    }
    
    public func notify<Value>(value: Value, to target: AnyObserver) {
        target.notify(value: value)
    }
}
