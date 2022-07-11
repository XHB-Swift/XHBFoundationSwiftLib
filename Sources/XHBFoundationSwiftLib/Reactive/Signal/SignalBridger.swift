//
//  SignalBridger.swift
//  
//
//  Created by xiehongbiao on 2022/7/11.
//

import Foundation


final public class SignalBridger<Value, Failure: Error>: Signal {
    
    private var broadcaster: AnyObservable<Value, Failure>?
    private var observer: AnyObserver<Value, Failure>?
    private var requirement: Requirement = .none
    private let lock: DispatchSemaphore = .init(value: 1)
    
    public init() {}
    
    public init<Ob: Observable, O: Observer>(observable: Ob, observer: O)
    where Value == Ob.Output, Ob.Output == O.Input, Failure == Ob.Failure, Ob.Failure == O.Failure {
        bind(observable: observable, to: observer)
    }
    
    public func bind<Ob: Observable, O: Observer>(observable: Ob, to observer: O)
    where Value == Ob.Output, Ob.Output == O.Input, Failure == Ob.Failure, Ob.Failure == O.Failure {
        self.broadcaster = .init(observable)
        self.observer = .init(observer)
    }
    
    public func cancel() {
        lock.wait()
        defer { lock.signal() }
        observer = nil
        broadcaster = nil
    }
    
    public func request(_ requirement: Requirement) {
        lock.wait()
        defer { lock.signal() }
        if requirement == .unlimited {
            self.requirement = requirement
        } else {
            self.requirement += requirement
        }
    }
}
