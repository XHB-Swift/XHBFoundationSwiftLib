//
//  SelectorObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class SelectorObserver<Base: NSObject, Sender>: NSObject, PairedObserver {
    
    public typealias Action = (Sender) -> Void
    
    open var identifier: UUID
    public weak var base: Base?
    public var action: Action?
    
    public let selector: Selector = #selector(selectorObserverAction(_:))
    
    public override init() {
        self.identifier = UUID()
        super.init()
    }
    
    public init(_ base: Base?, _ action: Action?) {
        self.base = base
        self.action = action
        self.identifier = UUID()
    }
    
    @objc public func selectorObserverAction(_ sender: Any) {
        guard let _sender = sender as? Sender,
              let action = self.action else { return }
        action(_sender)
    }
    
    public func notify<Value>(oldValue: Value, newValue: Value) {
        
    }
}
