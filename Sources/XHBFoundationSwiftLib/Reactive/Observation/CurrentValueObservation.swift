//
//  CurrentValueObservation.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

final public class CurrentValueObservation<Output, Failure: Error>: Observation {
    
    public typealias Output = Output
    public typealias Failure = Failure
    
    private var observers: ContiguousArray<AnyObserver<Output, Failure>> = .init()
    
    public var value: Output {
        didSet {
            send(value)
        }
    }
    
    public init(_ value: Output) {
        self.value = value
    }
    
    public func send(_ signal: Signal) {
        observers.forEach { observer in
            observer.receive(signal)
        }
    }
    
    public func send(_ value: Output) {
        observers.forEach { observer in
            observer.receive(value)
        }
    }
    
    public func send(_ failure: Failure) {
        observers.forEach { observer in
            observer.receive(.failure(failure))
        }
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        observers.append(observer.eraseToAnyObserver())
    }
}

extension CurrentValueObservation where Failure == Never {
    
    @discardableResult
    public func bind<Target: AnyObject>(target: Target,
                                        to keyPath: ReferenceWritableKeyPath<Target, Output>) -> CurrentValueObservation<Output, Failure> {
        let closureNeverOb: ClosureNeverObserver<Output> = .init { [weak target] in target?[keyPath: keyPath] = $0 }
        subscribe(closureNeverOb)
        return self
    }
    
    @discardableResult
    public func bind<Target: AnyObject, Value>(target: Target,
                                               to keyPath: ReferenceWritableKeyPath<Target, Value>,
                                               transform: @escaping (Output) -> Value) -> CurrentValueObservation<Output, Failure> {
        let closureNeverOb: ClosureNeverObserver<Value> = .init { [weak target] in target?[keyPath: keyPath] = $0 }
        map(transform).subscribe(closureNeverOb)
        return self
    }
}
