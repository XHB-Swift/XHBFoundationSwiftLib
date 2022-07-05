//
//  NSObject+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

extension NSObject {
    
    private static var NSObjectSpecifiedValueObservbaleBindingKey: Void?
    private static var NSObjectSpecifiedOptionalValueObservbaleBindingKey: Void?
    
    open func specifiedValueObservable<Value>(value: Value,
                                              queue: DispatchQueue? = nil) -> CurrentValueObservation<Value,Never> {
        return runtimePropertyLazyBinding(&Self.NSObjectSpecifiedValueObservbaleBindingKey, { .init(value) })
    }
    
    open func specifiedOptinalValueObservable<Value>(queue: DispatchQueue? = nil) -> CurrentValueObservation<Value?,Never> {
        return runtimePropertyLazyBinding(&Self.NSObjectSpecifiedOptionalValueObservbaleBindingKey, { .init(nil) })
    }
}
