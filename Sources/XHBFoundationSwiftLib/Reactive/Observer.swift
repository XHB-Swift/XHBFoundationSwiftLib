//
//  Observer.swift
//  
//
//  Created by 谢鸿标 on 2022/6/30.
//


import Foundation

public typealias ObserverClosure<Observer: AnyObject, Value> = (Observer?, Value) -> Void

open class AnyObserverContainer {
    
    let hashString: UUID
    open var closure: Any?
    open weak var observer: AnyObject?
    
    public init() {
        self.hashString = UUID()
    }
    
    public init(_ observer: AnyObject, _ closure: Any) {
        self.hashString = UUID()
        self.observer = observer
        self.closure = closure
    }
    
    open func notify<Value>(value: Value) {
        guard let closure = closure as? ObserverClosure<AnyObject, Value> else {
            return
        }
        closure(observer, value)
    }
    
    open func observerIsNil() -> Bool {
        return observer == nil
    }
}

open class ObserverContainer<Observer: AnyObject>: AnyObserverContainer {
    
    open override func notify<Value>(value: Value) {
        guard let closure = closure as? ObserverClosure<Observer, Value> else {
            return
        }
        closure(observer as? Observer, value)
    }
}

extension AnyObserverContainer: Hashable {

    public static func == (lhs: AnyObserverContainer, rhs: AnyObserverContainer) -> Bool {
        return lhs.hashString == rhs.hashString
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashString)
    }
}
