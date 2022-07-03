//
//  NSObject+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

extension NSObject {
    
    private static var NSObjectAnyObservableBindingKey: Void?
    private static var NSObjectAnyValueObservbaleBindingKey: Void?
    private static var NSObjectSpecifiedValueObservbaleBindingKey: Void?
    
    open var anyObservable: AnyObservable {
        return runtimePropertyLazyBinding(&Self.NSObjectAnyObservableBindingKey, { AnyObservable() })
    }
    
    open var anyValueObservable: ValueObservable<Any> {
        return runtimePropertyLazyBinding(&Self.NSObjectAnyValueObservbaleBindingKey, { ValueObservable<Any>() })
    }
    
    open func specifiedValueObservable<Value>(value: Value? = nil,
                                              queue: DispatchQueue? = nil) -> ValueObservable<Value> {
        return runtimePropertyLazyBinding(&Self.NSObjectSpecifiedValueObservbaleBindingKey, { ValueObservable(observedValue: value, queue: queue) })
    }
}
