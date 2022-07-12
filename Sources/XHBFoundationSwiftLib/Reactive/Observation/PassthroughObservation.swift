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
    private var anyObserver: AnyObserver<Output, Failure>?
    
    public init() {}
    
    public func send(_ signal: Signal) {
        anyObserver?.receive(signal)
    }
    
    public func send(_ value: Output) {
        anyObserver?.receive(value)
    }
    
    public func send(_ failure: Failure) {
        anyObserver?.receive(.failure(failure))
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        anyObserver = .init(observer)
    }
}
