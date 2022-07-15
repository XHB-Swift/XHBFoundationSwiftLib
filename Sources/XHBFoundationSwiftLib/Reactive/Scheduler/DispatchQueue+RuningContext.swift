//
//  DispatchQueue+RunningContext.swift
//  
//
//  Created by 谢鸿标 on 2022/7/15.
//

import Foundation

extension DispatchQueue: RunningContext {
    
    public var current: Time { .init(.now()) }
    
    public func run(action: @escaping () -> Void) {
        run(options: nil, action)
    }
    
    public func run(options: Options?, _ action: @escaping () -> Void) {
        async(group: options?.group, qos: options?.qos ?? .unspecified, flags: options?.flags ?? [], execute: action)
    }
    
    public func run(after time: Time, options: Options?, _ action: @escaping () -> Void) {
        run(after: time, interval: .seconds(0), options: options, action)
    }
    
    public func run(after time: Time, interval: Time.Stride, options: Options?, _ action: @escaping () -> Void) {
        asyncAfter(deadline: time.advanced(by: interval).dispatchTime,
                   qos: options?.qos ?? .unspecified,
                   flags: options?.flags ?? [],
                   execute: action)
    }
}

extension DispatchQueue {
    
    public struct Time: Strideable, Hashable {
        
        public var dispatchTime: DispatchTime
        public var hashValue: Int { Int(dispatchTime.rawValue) }
        
        public init(_ time: DispatchTime) {
            self.dispatchTime = time
        }
        
        public func distance(to other: DispatchQueue.Time) -> Stride {
            return .init(integerLiteral: Int(dispatchTime.rawValue - other.dispatchTime.rawValue))
        }
        
        public func advanced(by n: Stride) -> DispatchQueue.Time {
            return .init(.init(uptimeNanoseconds: UInt64(n.magnitude) + dispatchTime.uptimeNanoseconds))
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(hashValue)
        }
        
        public struct Stride: Comparable, SignedNumeric, ExpressibleByFloatLiteral, Hashable, TimeStride {
            
            public typealias Magnitude = Int
            public typealias FloatLiteralType = Double
            public typealias IntegerLiteralType = Int
            
            public var magnitude: Int
            public var hashValue: Int { magnitude }
            public var timeInterval: DispatchTimeInterval { return innerTimeInterval }
            private var innerTimeInterval: DispatchTimeInterval
            
            public init(_ timeInterval: DispatchTimeInterval) {
                self.innerTimeInterval = timeInterval
                switch timeInterval {
                case .seconds(let s):
                    self.magnitude = s * 1000000000
                case .milliseconds(let mls):
                    self.magnitude = mls * 1000000
                case .microseconds(let mcs):
                    self.magnitude = mcs * 1000
                case .nanoseconds(let nns):
                    self.magnitude = nns
                case .never:
                    self.magnitude = 0
                @unknown default:
                    self.magnitude = 0
                }
            }
            
            public init(floatLiteral value: Double) {
                self.magnitude = Int(value * 1000000000)
                self.innerTimeInterval = .nanoseconds(self.magnitude)
            }
            
            public init(integerLiteral value: Int) {
                self.magnitude = value * 1000000000
                self.innerTimeInterval = .seconds(value)
            }
            
            public init?<T>(exactly source: T) where T : BinaryInteger {
                self.magnitude = .init(source) * 1000000000
                self.innerTimeInterval = .seconds(self.magnitude)
            }
            
            public func hash(into hasher: inout Hasher) {
                hasher.combine(hashValue)
            }
            
            public static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.magnitude == rhs.magnitude
            }
            
            public static func < (lhs: Self, rhs: Self) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }
            
            public static func * (lhs: Self, rhs: Self) -> Self {
                return .init(.nanoseconds(lhs.magnitude * rhs.magnitude))
            }
            
            public static func + (lhs: Self, rhs: Self) -> Self {
                return .init(.nanoseconds(lhs.magnitude + rhs.magnitude))
            }
            
            public static func - (lhs: Self, rhs: Self) -> Self {
                return .init(.nanoseconds(lhs.magnitude - rhs.magnitude))
            }
            
            public static func -= (lhs: inout Self, rhs: Self) {
                lhs = .init(.nanoseconds(lhs.magnitude - rhs.magnitude))
            }
            
            public static func *= (lhs: inout Self, rhs: Self) {
                lhs = .init(.nanoseconds(lhs.magnitude * rhs.magnitude))
            }
            
            public static func += (lhs: inout Self, rhs: Self) {
                lhs = .init(.nanoseconds(lhs.magnitude + rhs.magnitude))
            }
            
            public static func seconds(_ s: Int) -> DispatchQueue.Time.Stride {
                return .init(integerLiteral: s)
            }
            
            public static func seconds(_ s: Double) -> DispatchQueue.Time.Stride {
                return .init(floatLiteral: s)
            }
            
            public static func milliseconds(_ ms: Int) -> DispatchQueue.Time.Stride {
                return .init(.milliseconds(ms))
            }
            
            public static func microseconds(_ us: Int) -> DispatchQueue.Time.Stride {
                return .init(.microseconds(us))
            }
            
            public static func nanoseconds(_ ns: Int) -> DispatchQueue.Time.Stride {
                return .init(.nanoseconds(ns))
            }
        }
    }
    
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
