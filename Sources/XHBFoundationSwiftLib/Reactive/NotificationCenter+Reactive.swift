//
//  NotificationCenter+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class NotificationCenterObserverContainer: SelectorObserverContainer<NotificationCenter> {
    
    public typealias Action = (Notification) -> Void
    
    deinit {
        let notificationCenter = observer as? NotificationCenter
        notificationCenter?.removeObserver(self)
        #if DEBUG
        print("Released NotificationCenterObserverContainer = \(self)")
        #endif
    }
    
    public init(_ observer: NotificationCenter?,
                _ name: Notification.Name,
                _ action: @escaping Action) {
        super.init(observer, action)
        observer?.addObserver(self, selector: self.selector, name: name, object: nil)
    }
    
    public override func selectorObserverAction(_ sender: Any) {
        guard let notification = sender as? Notification,
              let closure = self.closure as? Action else { return }
        closure(notification)
    }
}

extension Observable {
    
    public func add(observer: NotificationCenter = .default,
                    name: NSNotification.Name,
                    action: @escaping NotificationCenterObserverContainer.Action) {
        add(observer: NotificationCenterObserverContainer(observer, name, action))
    }
}

extension NotificationCenter {
    
    private static var NotificationCenterSelfBindingKey: Void?
    
    @discardableResult
    open func subscribe<Value>(value: Value,
                               name: Notification.Name,
                               action: @escaping NotificationCenterObserverContainer.Action) -> Observable<Value> {
        let observer = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return Observable<Value>(observedValue: value)
        }
        observer.add(observer: self, name: name, action: action)
        return observer
    }
    
    @discardableResult
    open func subscribe<Observer: AnyObject, Value>(value: Value,
                                                    observer: Observer,
                                                    keyPath: ReferenceWritableKeyPath<Observer, Value>,
                                                    name: Notification.Name,
                                                    action: @escaping (Notification) -> Value) -> Observable<Value> {
        let ob = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return Observable<Value>(observedValue: value)
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
                                                    action: @escaping (Notification) -> Value?) -> Observable<Value> {
        let ob = runtimePropertyLazyBinding(&Self.NotificationCenterSelfBindingKey) {
            return Observable<Value>(observedValue: value)
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
