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
        
        public init(input: Input, predicate: @escaping (Input.Output) -> Bool) {
            self.input = input
            self.predicate = predicate
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Bool == Ob.Input {
            let closureObserver: ClosureObserver<Input.Output, Failure> = .init({
                let contains = predicate($0)
                observer.receive(contains)
            }, {
                observer.receive(.failure($0))
            })
            input.subscribe(closureObserver)
        }
    }
}

extension Observable {
    
    public func contains(where predicate: @escaping (Output) -> Bool) -> Observables.ContainsWhere<Self> {
        return .init(input: self, predicate: predicate)
    }
}
