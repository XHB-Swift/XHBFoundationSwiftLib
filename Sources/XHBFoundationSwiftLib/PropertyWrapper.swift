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
@frozen public struct ThreadSafe<Value> {
    
    private var storedValue: Value
    private let lock = DispatchSemaphore(value: 1)
    
    public var wrappedValue: Value {
        set {
            lock.wait()
            storedValue = newValue
            lock.signal()
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return storedValue
        }
    }
    
    public init(wrappedValue: Value) {
        self.storedValue = wrappedValue
    }
}

@propertyWrapper
final public class Observable<Value> {

    private var queue: DispatchQueue? = nil
    private let lock = DispatchSemaphore(value: 1)
    private var objectObservers = Set<AnyObserverContainer>()
    private var storedValue: Value
    
    deinit {
        #if DEBUG
        print("self = \(self) released")
        #endif
    }
    
    public var wrappedValue: Value {
        set {
            lock.wait()
            storedValue = newValue
            notifyAll(storedValue)
            lock.signal()
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return storedValue
        }
    }
    public var projectedValue: Observable<Value> { return self }

    public init(wrappedValue: Value,
                queue: DispatchQueue? = nil) {
        self.storedValue = wrappedValue
        self.queue = queue
    }
}

extension Observable {
    
    public typealias ObserverClosure<Observer: AnyObject> = (Observer?, Value) -> Void
    
    public func add<Observer: AnyObject>(observer: Observer, closure: @escaping ObserverClosure<Observer>) {
        let newOne = ObserverContainer<Observer>(observer, closure)
        objectObservers.insert(newOne)
    }
    
    private func notifyAll(_ value: Value) {
        if objectObservers.isEmpty { return }
        objectObservers.forEach { [weak self] observerContainer in
            self?.notify(value: value, to: observerContainer)
        }
        objectObservers = objectObservers.filter { !$0.observerIsNil() }
    }
    
    private func notify(value: Value, to target: AnyObserverContainer) {
        if let queue = queue {
            queue.async {
                target.notify(value: value)
            }
        } else {
            target.notify(value: value)
        }
    }
}

extension Observable {
    
    fileprivate class AnyObserverContainer {
        
        let hashString: UUID
        var closure: Any?
        weak var observer: AnyObject?
        
        init() {
            self.hashString = UUID()
        }
        
        init(_ observer: AnyObject, _ closure: Any) {
            self.observer = observer
            self.closure = closure
            self.hashString = UUID()
        }
        
        func notify(value: Value) {
            guard let closure = closure as? ObserverClosure<AnyObject> else {
                return
            }
            closure(observer, value)
        }
        
        func observerIsNil() -> Bool {
            return observer == nil
        }
    }
    
    fileprivate class ObserverContainer<Observer: AnyObject>: AnyObserverContainer {
        
        override func notify(value: Value) {
            guard let closure = closure as? ObserverClosure<Observer> else {
                return
            }
            closure(observer as? Observer, value)
        }
    }
}

extension Observable.AnyObserverContainer: Hashable {

    static func == (lhs: Observable.AnyObserverContainer, rhs: Observable.AnyObserverContainer) -> Bool {
        return lhs.hashString == rhs.hashString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashString)
    }
}

extension Observable {
    
    public func add<Observer: AnyObject>(observer: Observer,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value>) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject>(observer: Observer,
                                         at keyPath: ReferenceWritableKeyPath<Observer, Value?>) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = value
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T>,
                                            convert: @escaping (Value) -> T) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = convert(value)
        }
    }
    
    public func add<Observer: AnyObject, T>(observer: Observer,
                                            at keyPath: ReferenceWritableKeyPath<Observer, T?>,
                                            convert: @escaping (Value) -> T?) {
        add(observer: observer) { ob, value in
            guard let strongOb = ob else { return }
            strongOb[keyPath: keyPath] = convert(value)
        }
    }
}
