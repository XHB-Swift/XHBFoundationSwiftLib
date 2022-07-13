//
//  Observables+TryLastWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct TryLastWhere<Input: Observable>: Observable {
        
        public typealias Output = Input.Output
        public typealias Failure = Error
        
        public let input: Input
        public let predicate: (Output) throws -> Bool
        private let _signalConduit: TryLastWhereSignalConduit<Output, Input.Failure>
        
        public init(input: Input, predicate: @escaping (Output) throws -> Bool) {
            self.input = input
            self.predicate = predicate
            self._signalConduit = .init(predicate: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Input.Output == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observable {
    
    public func tryLast(where predicate: @escaping (Output) throws -> Bool) -> Observables.TryLastWhere<Self> {
        return .init(input: self, predicate: predicate)
    }
    
}
