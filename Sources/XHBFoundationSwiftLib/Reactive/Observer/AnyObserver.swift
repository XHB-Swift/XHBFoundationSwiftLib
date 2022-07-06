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
    
    public func receive(_ signal: Observers.Signal<Input, Failure>) {
        self.box.receive(signal)
    }
}

extension AnyObserver {
    
    private class _AnyObserverBoxBase<Input, Failure: Error>: Observer {
        
        typealias Input = Input
        typealias Failure = Failure
        
        func receive(_ signal: Observers.Signal<Input, Failure>) {}
    }
    
    private class _AnyObserverBox<Base: Observer>: _AnyObserverBoxBase<Base.Input, Base.Failure> {
        
        var base: Base
        
        init(_ base: Base) {
            self.base = base
        }
        
        override func receive(_ signal: Observers.Signal<Base.Input, Base.Failure>) {
            self.base.receive(signal)
        }
    }
    
}

extension Observer {
    
    func eraseToAnyObserver() -> AnyObserver<Input, Failure> {
        return .init(self)
    }
}
