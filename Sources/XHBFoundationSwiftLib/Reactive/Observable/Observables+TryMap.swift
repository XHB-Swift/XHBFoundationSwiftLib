//
//  Observables+TryMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

extension Observables {
    
    public struct TryMap<Source, Output>: Observable where Source: Observable {
        
        public typealias Output = Output
        public typealias Failure = Error
        
        public let source: Source
        public let transform: (Source.Output) throws -> Output
        private let _signalConduit: TryTransformSignalConduit<Output, Source.Output, Source.Failure>
        
        public init(source: Source, transform: @escaping (Source.Output) throws -> Output) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(source: source, tryTransform: transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.TryMap {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.TryMap<Source, T> {
        return .init(source: source) {
            do {
                return try transform(self.transform($0))
            } catch {
                throw error
            }
        }
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Observables.TryMap<Source, T> {
        return .init(source: source) {
            do {
                return try transform(self.transform($0))
            } catch {
                throw error
            }
        }
    }
}

extension Observable {
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Observables.TryMap<Self, T> {
        return .init(source: self, transform: transform)
    }
}
