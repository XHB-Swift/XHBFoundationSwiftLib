//
//  NotificationCenter+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

extension NotificationCenter {
    
    public struct Observation: Observable {
        
        public typealias Output = Notification
        public typealias Failure = Never
        
        public let center: NotificationCenter
        public let name: Notification.Name
        public let object: AnyObject?
        
        private let _signalConduit: _NotificationSignalConduit
        
        public init(center: NotificationCenter, name: Notification.Name, object: AnyObject?) {
            self.center = center
            self.name = name
            self.object = object
            self._signalConduit = .init(source: center, name: name, object: object)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Never == Ob.Failure, Notification == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
    
    @discardableResult
    public func observe(for name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.Observation {
        return .init(center: self, name: name, object: object)
    }
}

extension NotificationCenter.Observation {
    
    private typealias NotificationObserver = AnyObserver<Notification, Never>
    
    private final class _NotificationSignalConduit: SelectorSignalConduit<NotificationCenter, Notification, Never> {
        
        private let lock: NSRecursiveLock = .init()
        
        override func cancel() {
            lock.lock()
            defer { lock.unlock() }
            source?.removeObserver(self)
            super.cancel()
        }
        
        init(source: NotificationCenter, name: Notification.Name, object: AnyObject?) {
            super.init(source: source)
            source.addObserver(self, selector: self.selector, name: name, object: object)
        }
        
        override func attach<O>(observer: O) where Notification == O.Input, Never == O.Failure, O : Observer {
            lock.lock()
            defer { lock.unlock() }
            super.attach(observer: observer)
        }
    }
}
