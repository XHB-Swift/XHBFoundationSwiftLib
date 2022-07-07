//
//  Observables+Contains.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

extension Observables {
    
    public struct Contains<Input>: Observable where Input: Observable, Input.Output : Equatable {
        
        public typealias Output = Bool
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let output: Input.Output
        
        public init(input: Input, output: Input.Output) {
            self.input = input
            self.output = output
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Bool == Ob.Input {
            let closureObserver: ClosureObserver<Input.Output, Failure> = .init({
                let contains = ($0 == output)
                observer.receive(.receiving(contains))
            }, {
                observer.receive(.failure($0))
            })
            input.subscribe(closureObserver)
        }
    }
}

extension Observable where Self.Output: Equatable {
    
    public func contains(_ output: Self.Output) -> Observables.Contains<Self> {
        return .init(input: self, output: output)
    }
}
