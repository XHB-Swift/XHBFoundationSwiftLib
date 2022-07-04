//
//  DataObserver.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

public typealias DataObserverClosure<T> = (_ old: T, _ new: T) -> Void

open class DataObserver<T>: Observer {
    
    public typealias Base = DataObserverClosure<T>
    
    open var base: Base?
    open var identifier: UUID
    
    public init(_ base: Base?) {
        self.base = base
        self.identifier = .init()
    }
    
    public func notify<Value>(oldValue: Value, newValue: Value) {
        guard let closure = self.base as? DataObserverClosure<Value> else {
            return
        }
        self.base?(oldValue, newValue)
    }
}
