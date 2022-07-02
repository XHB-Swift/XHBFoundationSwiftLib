//
//  AnyObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

public typealias ObserverClosure<Observer: AnyObject, Value> = (Observer, Value) -> Void

open class AnyObserver {
    
    let hashString: UUID
    open var closure: Any?
    open weak var base: AnyObject?
    
    public init() {
        self.hashString = UUID()
    }
    
    public init(_ observer: AnyObject?, _ closure: Any) {
        self.hashString = UUID()
        self.base = observer
        self.closure = closure
    }
    
    open func notify<Value>(value: Value) {
        guard let observer = self.base,
              let closure = closure as? ObserverClosure<AnyObject, Value> else {
            return
        }
        closure(observer, value)
    }
    
    open func observerIsNil() -> Bool {
        return base == nil
    }
}

extension AnyObserver: Hashable {

    public static func == (lhs: AnyObserver, rhs: AnyObserver) -> Bool {
        return lhs.hashString == rhs.hashString
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashString)
    }
}
