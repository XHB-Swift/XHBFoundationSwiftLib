//
//  AnyObservable.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

public struct AnyObservable<Output, Failure: Error>: Observable {
    
    public typealias Output = Output
    public typealias Failure = Failure
    
    private var box: _AnyObserverBoxBase<Output, Failure>
    
    public init<Ob: Observable>(_ observable: Ob) where Output == Ob.Output, Failure == Ob.Failure {
        self.box = _AnyObserverBox(observable)
    }
    
    public func subscribe<O>(_ observer: O) where O : Observer, Failure == O.Failure, Output == O.Input {
        self.box.subscribe(observer)
    }
}

extension AnyObservable {
    
    private class _AnyObserverBoxBase<O, F: Error>: Observable {
        typealias Output = O
        typealias Failure = F
        
        func subscribe<Ob>(_ observer: Ob) where Ob : Observer, F == Ob.Failure, O == Ob.Input {}
    }
    
    private class _AnyObserverBox<Base: Observable>: _AnyObserverBoxBase<Base.Output, Base.Failure> {
        
        var base: Base
        
        init(_ base: Base) {
            self.base = base
        }
        
        override func subscribe<Ob>(_ observer: Ob) where Base.Output == Ob.Input, Base.Failure == Ob.Failure, Ob : Observer {
            self.base.subscribe(observer)
        }
    }
    
}

extension Observable {
    
    func eraseToAnyObservable() -> AnyObservable<Output, Failure> {
        return .init(self)
    }
}
