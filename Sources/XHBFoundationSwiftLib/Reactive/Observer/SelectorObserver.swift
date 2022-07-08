//
//  SelectorObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class SelectorObserver<Input, Base: NSObject>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Never
    
    public weak var base: Base?
    public var closure: ClosureNeverObserver<Input>?
    
    public let selector: Selector = #selector(selectorObserverAction(_:))
    
    public init(base: Base, closure: ClosureNeverObserver<Input>? = nil) {
        self.base = base
        self.closure = closure
    }
    
    @objc public func selectorObserverAction(_ sender: Any) {
        guard let input = sender as? Input else { return }
        receive(input)
    }
    
    public func receive(_ input: Input) {
        self.closure?.receive(input)
    }
    
    public func receive(_ completion: Observers.Completion<Never>) {
        
    }
    
    deinit {
#if DEBUG
        print("Released = \(self)")
#endif
    }
}
