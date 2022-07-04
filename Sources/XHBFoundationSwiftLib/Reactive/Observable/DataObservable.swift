//
//  DataObservable.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

open class DataObservable<T>: Observable<DataObserver<T>> {
    
    private var queue: DispatchQueue? = nil
    private let lock = DispatchSemaphore(value: 1)
    private var storedValue: T?
    
    public var observedValue: T? {
        set {
            lock.wait()
            defer {
                lock.signal()
            }
            let oldValue = storedValue
            forEach { [weak self] ob in
                self?.notify(oldValue, newValue, to: ob)
            }
            storedValue = newValue
        }
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return storedValue
        }
    }
    
    public init(observedValue: T? = nil,
                queue: DispatchQueue? = nil) {
        self.storedValue = observedValue
        self.queue = queue
    }
    
    open func notify(_ old: T, _ new: T, to observer: DataObserver<T>) {
        if let queue = queue {
            queue.async {
                super.notify(old, new, to: observer)
            }
        } else {
            super.notify(old, new, to: observer)
        }
    }
}

extension DataObservable {
    
    @discardableResult
    open func bind<Target>(target: Target,
                           keyPath: ReferenceWritableKeyPath<Target, T>) -> DataObservable<T> {

        add(observer: DataObserver({ oldValue, newValue in
            target[keyPath: keyPath] = newValue
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target>(target: Target,
                           keyPath: ReferenceWritableKeyPath<Target, T?>) -> DataObservable<T> {
        add(observer: DataObserver({ oldValue, newValue in
            target[keyPath: keyPath] = newValue
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target, V>(target: Target,
                              keyPath: ReferenceWritableKeyPath<Target, V>,
                              convert: @escaping (T) -> V) -> DataObservable<T> {
        add(observer: DataObserver({ oldValue, newValue in
            target[keyPath: keyPath] = convert(newValue)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target, V>(target: Target,
                              keyPath: ReferenceWritableKeyPath<Target, V?>,
                              convert: @escaping (T) -> V?) -> DataObservable<T> {
        add(observer: DataObserver({ oldValue, newValue in
            target[keyPath: keyPath] = convert(newValue)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject>(target: Target,
                                      keyPath: ReferenceWritableKeyPath<Target, T>) -> DataObservable<T> {
        add(observer: DataObserver({ [weak target] oldValue, newValue in
            target?[keyPath: keyPath] = newValue
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject>(target: Target,
                                      keyPath: ReferenceWritableKeyPath<Target, T?>) -> DataObservable<T> {
        add(observer: DataObserver({ [weak target] oldValue, newValue in
            target?[keyPath: keyPath] = newValue
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject, V>(target: Target,
                                         keyPath: ReferenceWritableKeyPath<Target, V>,
                                         convert: @escaping (T) -> V) -> DataObservable<T> {
        add(observer: DataObserver({ [weak target] oldValue, newValue in
            target?[keyPath: keyPath] = convert(newValue)
        }))
        return self
    }
    
    @discardableResult
    open func bind<Target: AnyObject, V>(target: Target,
                                         keyPath: ReferenceWritableKeyPath<Target, V?>,
                                         convert: @escaping (T) -> V?) -> DataObservable<T> {
        add(observer: DataObserver({ [weak target] oldValue, newValue in
            target?[keyPath: keyPath] = convert(newValue)
        }))
        return self
    }
}
