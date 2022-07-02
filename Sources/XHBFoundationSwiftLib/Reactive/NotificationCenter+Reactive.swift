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
    open func subscribe<Value>(value: Value,
                               name: Notification.Name,
                               action: @escaping NotificationCenterObserver.Action) -> ValueObservable<Value> {
        let observer = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return ValueObservable<Value>(observedValue: value)
        }
        observer.add(observer: self, name: name, action: action)
        return observer
    }
    
    @discardableResult
    open func subscribe<Observer: AnyObject, Value>(value: Value,
                                                    observer: Observer,
                                                    keyPath: ReferenceWritableKeyPath<Observer, Value>,
                                                    name: Notification.Name,
                                                    action: @escaping (Notification) -> Value) -> ValueObservable<Value> {
        let ob = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return ValueObservable<Value>(observedValue: value)
        }
        ob.add(observer: self, name: name) { notification in
            observer[keyPath: keyPath] = action(notification)
        }
        return ob
    }
    
    @discardableResult
    open func subscribe<Observer: AnyObject, Value>(value: Value,
                                                    observer: Observer,
                                                    keyPath: ReferenceWritableKeyPath<Observer, Value?>,
                                                    name: Notification.Name,
                                                    action: @escaping (Notification) -> Value?) -> ValueObservable<Value> {
        let ob = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return ValueObservable<Value>(observedValue: value)
        }
        ob.add(observer: self, name: name) { notification in
            observer[keyPath: keyPath] = action(notification)
        }
        return ob
    }
    
    open func removeObservable() {
        let observable = objc_getAssociatedObject(self, &Self.NotificationCenterSelfBindingKey) as? AnyObservable
        observable?.remove(observer: self)
    }
}
