//
//  Observables+MakeConnectable.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

extension Observables {
    
    public struct MakeConnectable<Source: Observable>: ConnectableObservable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        private let _signalConduit: CommonSignalConduit<Source.Output, Source.Failure>
        
        public init(source: Source) {
            self._signalConduit = .init(source: source)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
        
        public func connect() -> Cancellable {
            self._signalConduit.send()
            return self._signalConduit
        }
    }
}

extension Observable where Failure == Never {
    
    public func makeConnectable() -> Observables.MakeConnectable<Self> {
        return .init(source: self)
    }
}
