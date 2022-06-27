//
//  PropertyWrapper.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation

#if os(iOS)

import UIKit

#else

import AppKit

#endif

@propertyWrapper
public struct Clamped<T: Comparable> {
    
    private var value: T
    private var validRange: ClosedRange<T>
    
    public var wrappedValue: T {
        set {
            value = min(max(newValue, validRange.lowerBound), validRange.upperBound)
        }
        get { return value }
    }
    
    init(wrappedValue: T, range: ClosedRange<T>) {
        self.value = wrappedValue
        self.validRange = range
    }
    
}

@propertyWrapper
public struct Trimmed {
    
    private var value = ""
    
    public var wrappedValue: String {
        get { return value }
        set {
            value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    public init(_ value: String) {
        self.value = value
    }
}

@propertyWrapper
public struct Path {
    
    public let root: String
    private var absolutePath = ""
    public var wrappedValue: String {
        get {
            return absolutePath
        }
        set {
            absolutePath = "\(root)/\(newValue)"
        }
    }
    
    public init(root: String) {
        self.root = root
    }
    
}

public protocol DefaultValue {
    
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

@propertyWrapper
public struct Default<T: DefaultValue> {
    
    public var wrappedValue: T.Value
    public init(wrappedValue: T.Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Default: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

extension Bool {
    public enum False: DefaultValue {
        public typealias Value = Bool
        public static var defaultValue = false
    }
    public enum True: DefaultValue {
        public typealias Value = Bool
        public static var defaultValue = true
    }
}

extension String {
    public enum Empty: DefaultValue {
        public typealias Value = String
        public static var defaultValue = ""
    }
}

extension Int {
    public enum Zero: DefaultValue {
        public typealias Value = Int
        public static var defaultValue: Int = 0
    }
}

extension Float {
    public enum Zero: DefaultValue {
        public typealias Value = Float
        public static var defaultValue: Float = 0
    }
}

extension Double {
    public enum Zero: DefaultValue {
        public typealias Value = Double
        public static var defaultValue: Double = 0
    }
}

extension CGFloat {
    public enum Zero: DefaultValue {
        public typealias Value = CGFloat
        public static var defaultValue: CGFloat = 0
    }
}

extension Default {
    public typealias True = Default<Bool.True>
    public typealias False = Default<Bool.False>
    public typealias IntZero = Default<Int.Zero>
    public typealias FloatZero = Default<Float.Zero>
    public typealias DoubleZero = Default<Double.Zero>
#if os(iOS) || os(macOS)
    public typealias CGFloatZero = Default<CGFloat.Zero>
#endif
    public typealias EmptyString = Default<String.Empty>
}

@propertyWrapper
public struct ConsoleLog<Value> {
    
    private var value: Value
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { return self.value }
        set {
            self.value = newValue
            #if DEBUG
            print("new value is \(newValue)")
            #endif
        }
    }
}

@propertyWrapper
public struct UserDefaultWrapper<Value> {
    
    public let key: String
    public let value: Value
    
    public var wrappedValue: Value {
        get { return UserDefaults.standard.object(forKey: key) as? Value ?? value }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct Localized {
    
    public let key: String
    public var tableName: String? = nil
    public var bundle: Bundle = .main
    public var value: String
    public var comment = ""
    
    public var wrappedValue: String {
        set {
            value = NSLocalizedString(key, tableName: tableName, bundle: bundle, value: newValue, comment: comment)
        }
        get {
            return value
        }
    }
}

@propertyWrapper
public struct NotificationCenterPost<T> {
    
    private var value: T
    private let name: Notification.Name
    
    public var wrappedValue: T {
        set {
            value = newValue
            NotificationCenter.default.post(name: name, object: value)
        }
        get {
            return value
        }
    }
    
    public init(wrappedValue: T, name: Notification.Name) {
        self.value = wrappedValue
        self.name = name
    }
}

public protocol Observer: AnyObject {
    associatedtype Value
    func notify(value: Value)
}

@propertyWrapper
final public class Observable<Target: Observer, Value> where Target.Value == Value {

    private var value: Value
    private let lock = DispatchSemaphore(value: 1)
    
    public var wrappedValue: Value {
        set {
            lock.wait()
            value = newValue
            notifyAll()
            lock.signal()
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return value
        }
    }
    
    public var projectedValue: Observable<Target, Value> { return self }
    
    fileprivate class _Observer {
        var hashString = "nil"
        var queue: DispatchQueue? = nil
        weak var target: Target? {
            didSet {
                if let target = target {
                    self.hashString = "\(target)"
                } else {
                    self.hashString = "nil"
                }
            }
        }
        
        init(target: Target?,
             queue: DispatchQueue? = nil) {
            self.target = target
            self.queue = queue
        }
        
        func notify(value: Value) {
            if let queue = queue {
                queue.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.target?.notify(value: value)
                }
            } else {
                target?.notify(value: value)
            }
        }
    }

    private var observers = Set<_Observer>()

    public init(wrappedValue: Value,
                observer: Target,
                queue: DispatchQueue? = nil) {
        self.value = wrappedValue
        add(observer: observer, queue: queue)
    }
    
    public func add(observer: Target,
                    queue: DispatchQueue? = nil) {
        let ob = _Observer(target: observer,
                           queue: queue)
        observers.insert(ob)
    }
    
    private func notifyAll() {
        for observer in observers {
            observer.notify(value: value)
        }
        removeNilIfPossilble()
    }
    
    private func removeNilIfPossilble() {
        observers = observers.filter { $0.target != nil }
    }
}

extension Observable._Observer: Hashable {
    
    static func == (lhs: Observable._Observer, rhs: Observable._Observer) -> Bool {
        return lhs.hashString == rhs.hashString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashString)
    }
}
