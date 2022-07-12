//
//  AnyObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

public struct AnyObserver<Input, Failure: Error>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Failure
    
    private var box: _AnyObserverBoxBase<Input, Failure>
    
    public init<O: Observer>(_ observer: O) where O.Input == Input, O.Failure == Failure {
        self.box = _AnyObserverBox(observer)
    }
    
    public func receive(_ signal: Signal) {
        self.box.receive(signal)
    }
    
    public func receive(_ completion: Observers.Completion<Failure>) {
        self.box.receive(completion)
    }
    
    public func receive(_ input: Input) {
        self.box.receive(input)
    }
}

extension AnyObserver {
    
    private class _AnyObserverBoxBase<Input, Failure: Error>: Observer {
        
        typealias Input = Input
        typealias Failure = Failure
        
        func receive(_ signal: Signal) {}
        func receive(_ input: Input) {}
        func receive(_ completion: Observers.Completion<Failure>) {}
    }
    
    private class _AnyObserverBox<Base: Observer>: _AnyObserverBoxBase<Base.Input, Base.Failure> {
        
        var base: Base
        
        init(_ base: Base) {
            self.base = base
        }
        
        override func receive(_ signal: Signal) {
            self.base.receive(signal)
        }
        
        override func receive(_ input: Base.Input) {
            self.base.receive(input)
        }
        
        override func receive(_ completion: Observers.Completion<Base.Failure>) {
            self.base.receive(completion)
        }
    }
    
}

extension Observer {
    
    func eraseToAnyObserver() -> AnyObserver<Input, Failure> {
        return .init(self)
    }
}
