//
//  Observables+Catch.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct Catch<Source, New>: Observable
    where Source: Observable, New: Observable, Source.Output == New.Output {
        
        public typealias Output = Source.Output
        public typealias Failure = New.Failure
        
        public let source: Source
        public let handler: (Source.Failure) -> New
        
        private let _signalConduit: _CatchErrorSignalConduit<Source, New>
        
        public init(source: Source, handler: @escaping (Source.Failure) -> New) {
            self.source = source
            self.handler = handler
            self._signalConduit = .init(handler)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, New.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.Catch {
    
    fileprivate final class _CatchErrorSignalConduit<Old: Observable, New: Observable>: OneToOneSignalConduit<New.Output, New.Failure, Old.Output, Old.Failure> {
        
        private var newObservable: AnyObservable<New.Output, New.Failure>?
        
        let handler: (Old.Failure) -> New
        
        init(_ handler: @escaping (Old.Failure) -> New) {
            self.handler = handler
        }
        
        override func receive(failure: Old.Failure) {
            guard let observer = anyObserver else {
                return
            }
            newObservable = .init(handler(failure))
            newObservable?.subscribe(observer)
            observer.receive(self)
        }
    }
}

extension Observable {
    
    public func `catch`<Ob: Observable>(_ handler: @escaping (Failure) -> Ob) -> Observables.Catch<Self, Ob> where Output == Ob.Output {
        return .init(source: self, handler: handler)
    }
}
