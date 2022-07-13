//
//  SignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/11.
//

import Foundation

class SignalConduit: Signal {
    
    private(set) var requirement: Requirement = .none
    let lock: NSRecursiveLock = .init()
    
    init() {}
    
    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        dispose()
    }
    
    func request(_ requirement: Requirement) {
        lock.lock()
        defer { lock.unlock() }
        if requirement == .unlimited {
            self.requirement = requirement
        } else {
            self.requirement += requirement
        }
        send()
    }
    
    func send() {}
    func dispose() {}
}

