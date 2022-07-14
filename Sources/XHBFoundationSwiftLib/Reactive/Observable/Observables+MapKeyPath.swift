//
//  Observables+MapKeyPath.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct MapKeyPath<Source, Output>: Observable where Source : Observable {
        
        public typealias Output = Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let keyPath: KeyPath<Source.Output, Output>
        private let _signalConduit: TransformSignalConduit<Output, Source.Output, Failure>
        
        public init(source: Source, keyPath: KeyPath<Source.Output, Output>) {
            self.source = source
            self.keyPath = keyPath
            self._signalConduit = .init(transform: { $0[keyPath: keyPath] })
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observable {
    
    public func map<T>(_ keyPath: KeyPath<Self.Output, T>) -> Observables.MapKeyPath<Self, T> {
        return .init(source: self, keyPath: keyPath)
    }
    
}
