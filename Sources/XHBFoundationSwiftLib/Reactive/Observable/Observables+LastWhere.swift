//
//  Observables+LastWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct LastWhere<Source: Observable>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let predicate: (Output) -> Bool
        private let _signalConduit: LastWhereSignalConduit<Output, Failure>
        
        public init(source: Source, predicate: @escaping (Output) -> Bool) {
            self.source = source
            self.predicate = predicate
            self._signalConduit = .init(predicate: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observable {
    
    public func last(where predicate: @escaping (Output) -> Bool) -> Observables.LastWhere<Self> {
        return .init(source: self, predicate: predicate)
    }
}
