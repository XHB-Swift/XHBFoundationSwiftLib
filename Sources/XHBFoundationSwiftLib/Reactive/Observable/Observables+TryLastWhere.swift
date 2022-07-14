//
//  Observables+TryLastWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct TryLastWhere<Source: Observable>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Error
        
        public let source: Source
        public let predicate: (Output) throws -> Bool
        private let _signalConduit: TryLastWhereSignalConduit<Output, Source.Failure>
        
        public init(input: Source, predicate: @escaping (Output) throws -> Bool) {
            self.source = input
            self.predicate = predicate
            self._signalConduit = .init(predicate: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observable {
    
    public func tryLast(where predicate: @escaping (Output) throws -> Bool) -> Observables.TryLastWhere<Self> {
        return .init(input: self, predicate: predicate)
    }
    
}
