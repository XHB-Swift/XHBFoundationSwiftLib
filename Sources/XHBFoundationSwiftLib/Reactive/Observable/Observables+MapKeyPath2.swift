//
//  Observables+MapKeyPath2.swift
//  
//
//  Created by xiehongbiao on 2022/7/21.
//

import Foundation

extension Observables {
    
    public struct MapKeyPath2<Source: Observable, Output0, Output1>: Observable {
        
        public typealias Output = (Output0, Output1)
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let keyPath0: KeyPath<Source.Output, Output0>
        public let keyPath1: KeyPath<Source.Output, Output1>
        private let _signalConduit: TransformSignalConduit<Output, Source.Output, Failure>
        
        public init(source: Source, keyPath0: KeyPath<Source.Output, Output0>, keyPath1: KeyPath<Source.Output, Output1>) {
            self.source = source
            self.keyPath0 = keyPath0
            self.keyPath1 = keyPath1
            self._signalConduit = .init(source: source, transform: { ($0[keyPath: keyPath0], $0[keyPath: keyPath1]) })
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, (Output0, Output1) == Ob.Input {
            _signalConduit.attach(observer: observer)
        }
    }
}

extension Observable {
    
    public func map<T0, T1>(_ keyPath0: KeyPath<Output, T0>, _ keyPath1: KeyPath<Output, T1>) -> Observables.MapKeyPath2<Self, T0, T1> {
        return .init(source: self, keyPath0: keyPath0, keyPath1: keyPath1)
    }
    
}
