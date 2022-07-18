//
//  Observables+Filter.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct Filter<Source>: Observable where Source: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let isIncluded: (Source.Output) -> Bool
        private let _signalConduit: FilterSignalConduit<Output, Failure>
        
        public init(source: Source, isIncluded: @escaping (Source.Output) -> Bool) {
            self.source = source
            self.isIncluded = isIncluded
            self._signalConduit = .init(source: source, isIncluded)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            _signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Filter {
    
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Observables.Filter<Source> {
        return .init(source: source, isIncluded: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Observables.TryFilter<Source> {
        return .init(source: source, isIncluded: isIncluded)
    }
}

extension Observable {
    
    public func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> Observables.Filter<Self> {
        return .init(source: self, isIncluded: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: @escaping (Self.Output) throws -> Bool) -> Observables.TryFilter<Self> {
        return .init(source: self, isIncluded: isIncluded)
    }
}
