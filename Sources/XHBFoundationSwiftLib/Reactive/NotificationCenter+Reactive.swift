//
//  NotificationCenter+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

extension NotificationCenter {
    
    public struct ObservableCenter: Observable {
        
        public typealias Output = Notification
        public typealias Failure = Never
        
        public let center: NotificationCenter
        public let name: Notification.Name
        public let object: AnyObject?
        
        private let boxContainer: _ObservableCenterBox
        
        public init(center: NotificationCenter, name: Notification.Name, object: AnyObject?) {
            self.center = center
            self.name = name
            self.object = object
            self.boxContainer = .init(center, name, object)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Never == Ob.Failure, Notification == Ob.Input {
            self.boxContainer.subscribe(observer)
        }
    }
    
    @discardableResult
    public func observe(for name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.ObservableCenter {
        return .init(center: self, name: name, object: object)
    }
}

extension NotificationCenter.ObservableCenter {
    
    private typealias NotificationObserver = AnyObserver<Notification, Never>
    
    private final class _ObservableCenterBox: SelectorObserver<Notification> {
         
        private var baseArray: ContiguousArray<NotificationObserver>
        
        deinit {
            let center = self.base as? NotificationCenter
            print("Released _ObservableCenterBoxBase = \(self)")
            center?.removeObserver(self)
        }
        
        init(_ center: NotificationCenter, _ name: Notification.Name, _ object: AnyObject?) {
            self.baseArray = .init()
            super.init(base: center)
            center.addObserver(self, selector: self.selector, name: name, object: object)
            self.closure = .init({ [weak self] sender in
                self?.baseArray.forEach { $0.receive(sender) }
            })
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Never == Ob.Failure, Notification == Ob.Input {
            self.baseArray.append(observer.eraseToAnyObserver())
        }
        
    }
    
}
