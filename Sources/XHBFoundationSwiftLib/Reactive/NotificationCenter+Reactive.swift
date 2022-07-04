//
//  NotificationCenter+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

extension Observable where Ob == NotificationCenterObserver {
    
    open func add(observer: NotificationCenter = .default,
                  name: NSNotification.Name,
                  action: @escaping SelectorObserver<NotificationCenter,Notification>.Action) {
        add(observer: NotificationCenterObserver(observer, name, action))
    }
}

extension NotificationCenter {
    
    private static var NotificationCenterSelfBindingKey: Void?
    
    @discardableResult
    open func subscribe(name: Notification.Name,
                        queue: DispatchQueue? = nil,
                        action: @escaping NotificationCenterObserver.Action) -> Observable<NotificationCenterObserver> {
        let ob = notificationObservable
        ob.add(observer: self, name: name, action: action)
        return ob
    }
    
    @discardableResult
    open func subscribe<Observed: AnyObject, Value>(name: Notification.Name,
                                                    observed: Observed,
                                                    keyPath: ReferenceWritableKeyPath<Observed, Value>,
                                                    value: Value? = nil,
                                                    queue: DispatchQueue? = nil,
                                                    convert: @escaping (Notification) -> Value) -> Observable<NotificationCenterObserver> {
        return subscribe(name: name, queue: queue) { [weak observed] notification in
            observed?[keyPath: keyPath] = convert(notification)
        }
    }
    
    @discardableResult
    open func subscribe<Observed: AnyObject, Value>(name: Notification.Name,
                                                    observed: Observed,
                                                    keyPath: ReferenceWritableKeyPath<Observed, Value?>,
                                                    value: Value? = nil,
                                                    queue: DispatchQueue? = nil,
                                                    convert: @escaping (Notification) -> Value?) -> Observable<NotificationCenterObserver> {
        return subscribe(name: name, queue: queue) { [weak observed] notification in
            observed?[keyPath: keyPath] = convert(notification)
        }
    }
    
    open func removeObservable() {
        notificationObservable.remove(observer: self)
    }
}
