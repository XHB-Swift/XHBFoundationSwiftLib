//
//  Observables+TryFilter.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation


extension Observables {
    
    public struct TryFilter<Source>: Observable where Source: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Error
        
        public let source: Source
        public let isIncluded: (Source.Output) throws -> Bool
        private let _signalConduit: TryFilterSignalConduit<Output, Source.Failure>
        
        public init(source: Source, isIncluded: @escaping (Source.Output) throws -> Bool) {
            self.source = source
            self.isIncluded = isIncluded
            self._signalConduit = .init(isIncluded)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.TryFilter {
    
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Observables.TryFilter<Source> {
        return .init(source: source) { isIncluded($0) }
    }
    
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Observables.TryFilter<Source> {
        return .init(source: source, isIncluded: isIncluded)
    }
}
