//
//  Observables+LastWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct LastWhere<Input: Observable>: Observable {
        
        public typealias Output = Input.Output
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let predicate: (Output) -> Bool
        private let _signalConduit: LastWhereSignalConduit<Output, Failure>
        
        public init(input: Input, predicate: @escaping (Output) -> Bool) {
            self.input = input
            self.predicate = predicate
            self._signalConduit = .init(predicate: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observable {
    
    public func last(where predicate: @escaping (Output) -> Bool) -> Observables.LastWhere<Self> {
        return .init(input: self, predicate: predicate)
    }
}
