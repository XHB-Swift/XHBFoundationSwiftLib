//
//  SignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/11.
//

import Foundation

open class SignalConduit: Signal {
    
    private(set) var requirement: Requirement = .none
    public let lock: NSRecursiveLock = .init()
    
    public init() {}
    
    public func cancel() {
        lock.lock()
        defer { lock.unlock() }
        dispose()
    }
    
    public func request(_ requirement: Requirement) {
        lock.lock()
        defer { lock.unlock() }
        if requirement == .unlimited {
            self.requirement = requirement
        } else {
            self.requirement += requirement
        }
        send()
    }
    
    public func send() {}
    public func dispose() {}
}
