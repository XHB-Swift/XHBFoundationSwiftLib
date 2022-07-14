//
//  Observables+ContainsWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

extension Observables {
    
    public struct ContainsWhere<Source>: Observable where Source: Observable {
        
        public typealias Output = Bool
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let predicate: (Source.Output) -> Bool
        private let _signalConduit: TransformSignalConduit<Bool, Source.Output, Failure>
        
        public init(source: Source, predicate: @escaping (Source.Output) -> Bool) {
            self.source = source
            self.predicate = predicate
            self._signalConduit = .init(transform: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Bool == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observable {
    
    public func contains(where predicate: @escaping (Output) -> Bool) -> Observables.ContainsWhere<Self> {
        return .init(source: self, predicate: predicate)
    }
}
