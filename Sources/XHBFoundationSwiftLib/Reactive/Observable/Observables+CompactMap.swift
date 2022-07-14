//
//  Observables+CompactMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct CompactMap<Source: Observable, Output>: Observable {
        
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let transform: (Source.Output) -> Output?
        private let _signalConduit: _CompactMapSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Output) -> Output?) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.CompactMap {
    
    fileprivate final class _CompactMapSignalConduit: OneToOneSignalConduit<Output, Failure, Source.Output, Source.Failure> {
        
        let transform: (Source.Output) -> Output?
        
        init(_ transform: @escaping (Source.Output) -> Output?) {
            self.transform = transform
        }
        
        override func receive(value: Source.Output) {
            guard let v = transform(value) else { return }
            anyObserver?.receive(v)
        }
    }
}

extension Observables.CompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Observables.CompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = self.transform($0) else { return nil }
            return transform(v)
        })
    }
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.CompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = self.transform($0) else { return nil }
            return transform(v)
        })
    }
}

extension Observable {
    
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Observables.CompactMap<Self, T> {
        return .init(source: self, transform: transform)
    }
    
    
}
