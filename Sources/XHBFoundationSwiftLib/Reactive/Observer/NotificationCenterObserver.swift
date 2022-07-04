//
//  File.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class NotificationCenterObserver: SelectorObserver<NotificationCenter, Notification> {
    
    deinit {
        base?.removeObserver(self)
        #if DEBUG
        print("Released NotificationCenterObserverContainer = \(self)")
        #endif
    }
    
    public init(_ base: NotificationCenter?,
                _ name: Notification.Name,
                _ action: @escaping Action) {
        super.init(base, action)
        base?.addObserver(self, selector: self.selector, name: name, object: nil)
    }
}
