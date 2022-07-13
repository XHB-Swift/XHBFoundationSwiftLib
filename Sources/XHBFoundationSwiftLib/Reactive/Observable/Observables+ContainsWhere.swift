//
//  Observables+ContainsWhere.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

extension Observables {
    
    public struct ContainsWhere<Input>: Observable where Input: Observable {
        
        public typealias Output = Bool
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let predicate: (Input.Output) -> Bool
        private let _signalConduit: TransformSignalConduit<Bool, Input.Output, Failure>
        
        public init(input: Input, predicate: @escaping (Input.Output) -> Bool) {
            self.input = input
            self.predicate = predicate
            self._signalConduit = .init(transform: predicate)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Bool == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observable {
    
    public func contains(where predicate: @escaping (Output) -> Bool) -> Observables.ContainsWhere<Self> {
        return .init(input: self, predicate: predicate)
    }
}
