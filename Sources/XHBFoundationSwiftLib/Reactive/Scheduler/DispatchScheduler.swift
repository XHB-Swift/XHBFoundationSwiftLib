//
//  DispatchScheduler.swift
//  
//
//  Created by 谢鸿标 on 2022/7/16.
//

import Foundation

final public class DispatchScheduler: RunningContext {
    
    private var timer: DispatchSourceTimer?
    private let flags: DispatchSource.TimerFlags
    private var queue: DispatchQueue?
    
    private let lock = NSRecursiveLock()
    
    public var current: Time { .init(.now()) }
    public var tolerance: Time.Stride { .nanoseconds(0) }
    
    deinit {
#if DEBUG
        print("Released = \(self)")
#endif
        cancel()
    }
    
    public init(flags: DispatchSource.TimerFlags = [], queue: DispatchQueue? = nil) {
        self.queue = queue
        self.flags = flags
    }
    
    private func start() {
        lock.lock()
        defer { lock.unlock() }
        if timer != nil { return }
        timer = DispatchSource.makeTimerSource(flags: flags, queue: queue)
    }
    
    private func runCompletion(_ interval: Time.Stride, _ action: @escaping () -> Void) {
        action()
        if interval == .init(.never) {
            cancel()
        }
    }
    
    private func resumeIfPossible() {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            timer?.activate()
        } else {
            timer?.resume()
        }
    }
    
    public func cancel() {
        lock.lock()
        defer { lock.unlock() }
        if timer == nil { return }
        timer?.cancel()
        timer = nil
    }
    
    public func run(action: @escaping () -> Void) {
        run(options: nil, action)
    }
    
    public func run(options: Options?, _ action: @escaping () -> Void) {
        queue?.async(group: options?.group,
                     qos: options?.qos ?? .unspecified,
                     flags: options?.flags ?? []) {
            action()
        }
    }
    
    public func run(after time: Time, tolerance: Time.Stride, options: Options?, _ action: @escaping () -> Void) {
        run(after: time, interval: .init(.never), tolerance: tolerance, options: options, action)
    }
    
    public func run(after time: Time, interval: Time.Stride, tolerance: Time.Stride, options: Options?, _ action: @escaping () -> Void) {
        start()
        timer?.setEventHandler(qos: options?.qos ?? .unspecified, flags: options?.flags ?? []) { [weak self] in
            self?.runCompletion(interval,action)
        }
        timer?.schedule(deadline: time.dispatchTime, repeating: interval.timeInterval, leeway: tolerance.timeInterval)
        resumeIfPossible()
    }
}

extension DispatchScheduler: Cancellable {
}

extension DispatchScheduler {
    
    public typealias Options = Time.Options
    
    public struct Time: Strideable, Hashable {
        public var dispatchTime: DispatchTime
        public var hashValue: Int { Int(dispatchTime.rawValue) }
        
        public init(_ time: DispatchTime) {
            self.dispatchTime = time
        }
        
        public func distance(to other: Time) -> Stride {
            return .init(.nanoseconds(Int(dispatchTime.uptimeNanoseconds - other.dispatchTime.uptimeNanoseconds)))
        }
        
        public func advanced(by n: Stride) -> Time {
            return .init(.init(uptimeNanoseconds: UInt64(n.magnitude) + dispatchTime.uptimeNanoseconds))
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(hashValue)
        }
        
        public struct Stride: Comparable, SignedNumeric, ExpressibleByFloatLiteral, Hashable, TimeStride, CustomDebugStringConvertible {
            
            public typealias Magnitude = Int
            public typealias FloatLiteralType = Double
            public typealias IntegerLiteralType = Int
            
            public var magnitude: Int
            public var hashValue: Int { magnitude }
            public var debugDescription: String { "nanoseconds(\(magnitude))" }
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
            
            public static func seconds(_ s: Int) -> Time.Stride {
                return .init(integerLiteral: s)
            }
            
            public static func seconds(_ s: Double) -> Time.Stride {
                return .init(floatLiteral: s)
            }
            
            public static func milliseconds(_ ms: Int) -> Time.Stride {
                return .init(.milliseconds(ms))
            }
            
            public static func microseconds(_ us: Int) -> Time.Stride {
                return .init(.microseconds(us))
            }
            
            public static func nanoseconds(_ ns: Int) -> Time.Stride {
                return .init(.nanoseconds(ns))
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
    
}

extension DispatchScheduler {
    
    public static let main: DispatchScheduler = .init(queue: .main)
    public static let global: DispatchScheduler = .init(queue: .global())
}

extension DispatchScheduler {
    
    public static func observation(every interval: TimeInterval,
                                   tolerance: TimeInterval? = nil,
                                   on queue: DispatchQueue,
                                   flags: DispatchSource.TimerFlags = [],
                                   options: DispatchScheduler.Options? = nil) -> DispatchScheduler.Observation {
        return .init(interval: interval,
                     tolerance: tolerance,
                     flags: flags,
                     queue: queue,
                     options: options)
    }
    
    final public class Observation: ConnectableObservable {
        
        public typealias Output = Date
        public typealias Failure = Never
        
        final public let interval: TimeInterval
        final public let tolerance: TimeInterval?
        final public let queue: DispatchQueue
        final public let flags: DispatchSource.TimerFlags
        final public let options: DispatchScheduler.Options?
        
        private let _signalConduit: _SchedulerSignalConduit
        
        public init(interval: TimeInterval,
                    tolerance: TimeInterval? = nil,
                    flags: DispatchSource.TimerFlags = [],
                    queue: DispatchQueue,
                    options: DispatchScheduler.Options? = nil) {
            self.interval = interval
            self.tolerance = tolerance
            self.queue = queue
            self.options = options
            self.flags = flags
            self._signalConduit = .init(flags: flags,
                                        queue: queue,
                                        interval: interval,
                                        tolerance: tolerance,
                                        options: options)
        }
        
        public func connect() -> Cancellable {
            self._signalConduit.observersReceiveSignal()
            self._signalConduit.send()
            return self._signalConduit
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension DispatchScheduler.Observation {
    
    fileprivate final class _SchedulerSignalConduit: SignalConduit {
        
        private var waitingObserverIds: Set<UUID>
        private var allObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        private let timer: DispatchScheduler
        private let interval: TimeInterval
        private let tolerance: TimeInterval?
        private let options: DispatchScheduler.Options?
        
        init(flags: DispatchSource.TimerFlags = [],
             queue: DispatchQueue,
             interval: TimeInterval,
             tolerance: TimeInterval?,
             options: DispatchScheduler.Options?) {
            waitingObserverIds = .init()
            allObservers = .init()
            self.interval = interval
            self.tolerance = tolerance
            self.options = options
            self.timer = .init(flags: flags, queue: queue)
            super.init()
        }
        
        override func send() {
            let t: DispatchScheduler.Time.Stride
            if let setTValue = self.tolerance {
                t = .init(floatLiteral: setTValue)
            } else {
                t = timer.tolerance
            }
            timer.run(after: timer.current.advanced(by: .seconds(interval)),
                      interval: .init(floatLiteral: interval),
                      tolerance: t,
                      options: options) { [weak self] in
                self?.timerAction()
            }
        }
        
        func observersReceiveSignal() {
            allObservers
                .filter { waitingObserverIds.contains($0.key) }
                .forEach { $0.value.receive(self) }
        }
        
        private func timerAction() {
            let date = Date()
            allObservers
                .forEach { $0.value.receive(date) }
        }
        
        override func dispose() {
            timer.cancel()
            allObservers.removeAll()
            waitingObserverIds.removeAll()
        }
        
        func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            lock.lock()
            defer { lock.unlock() }
            let id = observer.identifier
            allObservers[id] = .init(observer)
            _ = waitingObserverIds.insert(id)
        }
    }
}
