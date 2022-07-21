//
//  SelectorSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/21.
//

import Foundation

open class SelectorSignalConduit<Source, Output, Failure: Error>: Signal {
    
    public let identifier: UUID = .init()
    
    private(set) var requirement: Requirement = .none
    private var observers: Dictionary<UUID, AnyObserver<Output, Failure>> = .init()
    
    public var source: Source?
    public let selector: Selector = #selector(selectorAction(_:))
    
    deinit { cancel() }
    
    public init() {}
    
    public init(source: Source?) {
        self.source = source
    }
    
    open func cancel() {
        source = nil
        requirement = .none
        observers.removeAll()
    }
    
    open func request(_ requirement: Requirement) {
        if self.requirement != requirement {
            self.requirement = requirement
        }
        if self.requirement == .none {
            return
        }
    }
    
    @objc public func selectorAction(_ sender: Any) {
        guard let output = sender as? Output else { return }
        observers.forEach { (_,observer) in
            observer.receive(output)
        }
    }
    
    open func attach<O: Observer>(observer: O) where O.Input == Output, O.Failure == Failure {
        observers[observer.identifier] = .init(observer)
        observer.receive(self)
    }
}
