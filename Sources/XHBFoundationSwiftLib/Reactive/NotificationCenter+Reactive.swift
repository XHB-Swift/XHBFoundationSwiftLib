//
//  NotificationCenter+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

extension ValueObservable {
    
    public func add(observer: NotificationCenter = .default,
                    name: NSNotification.Name,
                    action: @escaping NotificationCenterObserver.Action) {
        add(observer: NotificationCenterObserver(observer, name, action))
    }
}

extension NotificationCenter {
    
    private static var NotificationCenterSelfBindingKey: Void?
    
    @discardableResult
    open func subscribe<Value>(name: Notification.Name,
                               value: Value? = nil,
                               queue: DispatchQueue? = nil,
                               action: @escaping NotificationCenterObserver.Action) -> ValueObservable<Value> {
        let ob = specifiedValueObservable(value: value, queue: queue)
        ob.add(observer: self, name: name, action: action)
        return ob
    }
    
    @discardableResult
    open func subscribe<Observed: AnyObject, Value>(name: Notification.Name,
                                                    observed: Observed,
                                                    keyPath: ReferenceWritableKeyPath<Observed, Value>,
                                                    value: Value? = nil,
                                                    queue: DispatchQueue? = nil,
                                                    action: @escaping (Notification) -> Value) -> ValueObservable<Value> {
        return subscribe(name: name, value: value, queue: queue) { notification in
            observed[keyPath: keyPath] = action(notification)
        }
    }
    
    @discardableResult
    open func subscribe<Observed: AnyObject, Value>(name: Notification.Name,
                                                    observed: Observed,
                                                    keyPath: ReferenceWritableKeyPath<Observed, Value?>,
                                                    value: Value? = nil,
                                                    queue: DispatchQueue? = nil,
                                                    action: @escaping (Notification) -> Value?) -> ValueObservable<Value> {
        return subscribe(name: name, value: value, queue: queue) { notification in
            observed[keyPath: keyPath] = action(notification)
        }
    }
    
    open func removeObservable() {
        anyObservable.remove(observer: self)
        anyValueObservable.remove(observer: self)
    }
}
