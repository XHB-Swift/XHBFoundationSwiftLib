//
//  DispatchQueue+RunningContext.swift
//  
//
//  Created by 谢鸿标 on 2022/7/15.
//

import Foundation

extension DispatchQueue: RunningContext {
    
    public func run(action: @escaping () -> Void) {
        run(options: nil, action)
    }
    
    public func run(options: Options?, _ action: @escaping () -> Void) {
        async(group: options?.group, qos: options?.qos ?? .unspecified, flags: options?.flags ?? [], execute: action)
    }
    
    public func run(after time: Time, options: Options?, _ action: @escaping () -> Void) {
        run(after: time, interval: .seconds(0), options: options, action)
    }
    
    public func run(after time: Time, interval: TimeStride, options: Options?, _ action: @escaping () -> Void) {
        asyncAfter(deadline: time + interval, qos: options?.qos ?? .unspecified, flags: options?.flags ?? [], execute: action)
    }
}

extension DispatchQueue {
    
    public typealias Time = DispatchTime
    public typealias TimeStride = DispatchTimeInterval
    
    public struct Options {
        
        public var qos: DispatchQoS
        public var flags: DispatchWorkItemFlags
        public var group: DispatchGroup?
        
        public init(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], group: DispatchGroup? = nil) {
            self.qos = qos
            self.flags = flags
            self.group = group
        }
    }
}
