//
//  DataObservable.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

open class DataObserved<Output, Failure: Error>: Observable {
    
    public typealias Output = Output
    public typealias Failure = Failure
    
    private var queue: DispatchQueue? = nil
    private let lock = DispatchSemaphore(value: 1)
    private var observers: Array<AnyObserver<Output,Failure>>
    private var storedValue: Output?
    
    public var observedValue: Output? {
        set {
            lock.wait()
            defer {
                lock.signal()
            }
            storedValue = newValue
            self.observers.forEach { observer in
                guard let output = newValue else { return }
                observer.receive(output)
            }
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return storedValue
        }
    }
    
    public init(observedValue: Output? = nil,
                queue: DispatchQueue? = nil) {
        self.storedValue = observedValue
        self.queue = queue
        self.observers = .init()
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        self.observers.append(.init(observer))
    }
}

extension DataObserved where Failure == Never {
    
    @discardableResult
    open func bind<Target>(target: Target,
                           keyPath: ReferenceWritableKeyPath<Target, Output>) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ output in
            target[keyPath: keyPath] = output
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target>(target: Target,
                           keyPath: ReferenceWritableKeyPath<Target, Output?>) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ output in
            target[keyPath: keyPath] = output
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target, V>(target: Target,
                              keyPath: ReferenceWritableKeyPath<Target, V>,
                              convert: @escaping (Output) -> V) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ output in
            target[keyPath: keyPath] = convert(output)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target, V>(target: Target,
                              keyPath: ReferenceWritableKeyPath<Target, V?>,
                              convert: @escaping (Output) -> V?) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ output in
            target[keyPath: keyPath] = convert(output)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject>(target: Target,
                                      keyPath: ReferenceWritableKeyPath<Target, Output>) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ output in
            target[keyPath: keyPath] = output
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject>(target: Target,
                                      keyPath: ReferenceWritableKeyPath<Target, Output?>) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ [weak target] output in
            target?[keyPath: keyPath] = output
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject, V>(target: Target,
                                         keyPath: ReferenceWritableKeyPath<Target, V>,
                                         convert: @escaping (Output) -> V) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ [weak target] output in
            target?[keyPath: keyPath] = convert(output)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject, V>(target: Target,
                                         keyPath: ReferenceWritableKeyPath<Target, V?>,
                                         convert: @escaping (Output) -> V?) -> DataObserved<Output, Failure> {
        subscribe(ClosureObserver({ [weak target] output in
            target?[keyPath: keyPath] = convert(output)
        }))
        return self
    }
}
