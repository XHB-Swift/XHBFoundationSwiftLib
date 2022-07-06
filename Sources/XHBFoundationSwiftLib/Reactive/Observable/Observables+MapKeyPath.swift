//
//  Observables+MapKeyPath.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct MapKeyPath<Input, Output>: Observable where Input : Observable {
        
        public typealias Output = Output
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let keyPath: KeyPath<Input.Output, Output>
        
        public init(input: Input, keyPath: KeyPath<Input.Output, Output>) {
            self.input = input
            self.keyPath = keyPath
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Output == Ob.Input {
            let closureOb: ClosureObserver<Input.Output, Failure> =
                .init { observer.receive(.receiving($0[keyPath: self.keyPath])) } _: { observer.receive(.failure($0)) }
            input.subscribe(closureOb)
        }
    }
}

extension Observable {
    
    public func map<T>(_ keyPath: KeyPath<Self.Output, T>) -> Observables.MapKeyPath<Self, T> {
        return .init(input: self, keyPath: keyPath)
    }
    
}
