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
        private let _signalConduit: TransformSignalConduit<Bool, Input.Output, Failure>
        
        public init(input: Input, output: Input.Output) {
            self.input = input
            self.output = output
            self._signalConduit = .init(transform: { $0 == output })
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Bool == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observable where Self.Output: Equatable {
    
    public func contains(_ output: Self.Output) -> Observables.Contains<Self> {
        return .init(input: self, output: output)
    }
}
