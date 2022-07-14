//
//  PassthroughObservation.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

final public class PassthroughObservation<Output, Failure: Error>: Observation {
    
    public typealias Output = Output
    public typealias Failure = Failure
    private var observers: ContiguousArray<AnyObserver<Output, Failure>>
    
    deinit {
        observers.removeAll()
    }
    
    public init() {
        observers = .init()
    }
    
    public func send(_ signal: Signal) {
        observers.forEach {
            $0.receive(signal)
        }
    }
    
    public func send(_ value: Output) {
        observers.forEach {
            $0.receive(value)
        }
    }
    
    public func send(_ failure: Failure) {
        observers.forEach {
            $0.receive(.failure(failure))
        }
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        observers.append(.init(observer))
    }
}
