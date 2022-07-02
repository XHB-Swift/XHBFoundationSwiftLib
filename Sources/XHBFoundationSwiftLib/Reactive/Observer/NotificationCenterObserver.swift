//
//  File.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class NotificationCenterObserver: SelectorObserver<NotificationCenter> {
    
    public typealias Action = (Notification) -> Void
    
    deinit {
        let notificationCenter = self.base as? NotificationCenter
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
