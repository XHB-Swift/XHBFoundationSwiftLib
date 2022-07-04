//
//  NSObject+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

extension NSObject {
    
    private static var NSObjectAnyValueObservbaleBindingKey: Void?
    private static var NSObjectNotificationObservableBindingKey: Void?
    private static var NSObjectSpecifiedValueObservbaleBindingKey: Void?
    private static var NSObjectSpecifiedOptionalValueObservbaleBindingKey: Void?
    
    open var anyValueObservable: DataObservable<Any> {
        return runtimePropertyLazyBinding(&Self.NSObjectAnyValueObservbaleBindingKey, { .init() })
    }
    
    open var notificationObservable: Observable<NotificationCenterObserver> {
        return runtimePropertyLazyBinding(&Self.NSObjectNotificationObservableBindingKey, { .init() })
    }
    
    open func specifiedValueObservable<Value>(value: Value,
                                              queue: DispatchQueue? = nil) -> DataObservable<Value> {
        return runtimePropertyLazyBinding(&Self.NSObjectSpecifiedValueObservbaleBindingKey, { .init(observedValue: value,
                                                                                                    queue: queue) })
    }
    
    open func specifiedOptinalValueObservable<Value>(value: Value? = nil,
                                                     queue: DispatchQueue? = nil) -> DataObservable<Value?> {
        return runtimePropertyLazyBinding(&Self.NSObjectSpecifiedOptionalValueObservbaleBindingKey, { .init(queue: queue) })
    }
}
