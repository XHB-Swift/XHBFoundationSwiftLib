//
//  Observables+TryCompactMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct TryCompactMap<Source: Observable, Output>: Observable {
        
        public typealias Failure = Error
        
        public let source: Source
        public let transform: (Source.Output) throws -> Output?
        private let _signalConduit: _TryCompactMapSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Output) throws -> Output?) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.TryCompactMap {
    
    fileprivate final class _TryCompactMapSignalConduit: OneToOneSignalConduit<Output, Failure, Source.Output, Source.Failure> {
        
        let transform: (Source.Output) throws -> Output?
        
        init(_ transform: @escaping (Source.Output) throws -> Output?) {
            self.transform = transform
        }
        
        override func receive(value: Source.Output) {
            do {
                guard let v = try transform(value) else { return }
                anyObserver?.receive(v)
            } catch {
                anyObserver?.receive(.failure(error))
            }
        }
    }
}

extension Observables.TryCompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Observables.TryCompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = try self.transform($0) else { return nil }
            return try transform(v)
        })
    }
}

extension Observable {
    
    public func tryCompactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Observables.TryCompactMap<Self, T> {
        return .init(source: self, transform: transform)
    }
}
