//
//  SelectorObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class SelectorObserver<Observer: NSObject>: AnyObserver {
    
    public typealias Action = (Observer) -> Void
    
    public let selector: Selector = #selector(selectorObserverAction(_:))
    
    @objc public func selectorObserverAction(_ sender: Any) {
        guard let observer = sender as? Observer,
              let closure = self.closure as? Action else { return }
        closure(observer)
    }
}
