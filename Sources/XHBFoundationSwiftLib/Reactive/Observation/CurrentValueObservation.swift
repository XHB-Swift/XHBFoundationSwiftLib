//
//  CurrentValueObservation.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

public typealias CurrentValueNeverObservation<Output> = CurrentValueObservation<Output, Never>

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
