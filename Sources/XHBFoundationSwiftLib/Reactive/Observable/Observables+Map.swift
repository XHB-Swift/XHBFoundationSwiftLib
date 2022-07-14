//
//  Observables+Map.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct Map<Source, Output>: Observable where Source: Observable {
        
        public typealias Output = Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let transform: (Source.Output) -> Output
        private let _signalConduit: TransformSignalConduit<Output, Source.Output, Failure>
        
        public init(source: Source, transform: @escaping (Source.Output) -> Output) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(transform: transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.Map {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.Map<Source, T> {
        return .init(source: source) { transform(self.transform($0)) }
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
    
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Observables.Map<Self, T> {
        return .init(source: self, transform: transform)
    }
    
    public func replaceNil<T>(with output: T) -> Observables.Map<Self, T> where Self.Output == T? {
        return .init(source: self, transform: {  $0 ?? output })
    }
}
