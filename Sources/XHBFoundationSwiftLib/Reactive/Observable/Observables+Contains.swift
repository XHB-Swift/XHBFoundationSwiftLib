//
//  Observables+Contains.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

extension Observables {
    
    public struct Contains<Source>: Observable where Source: Observable, Source.Output : Equatable {
        
        public typealias Output = Bool
        public typealias Failure = Source.Failure
        
        public let input: Source
        public let output: Source.Output
        private let _signalConduit: TransformSignalConduit<Bool, Source.Output, Failure>
        
        public init(source: Source, output: Source.Output) {
            self.input = source
            self.output = output
            self._signalConduit = .init(source:source, transform: { $0 == output })
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Bool == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observable where Self.Output: Equatable {
    
    public func contains(_ output: Self.Output) -> Observables.Contains<Self> {
        return .init(source: self, output: output)
    }
}
