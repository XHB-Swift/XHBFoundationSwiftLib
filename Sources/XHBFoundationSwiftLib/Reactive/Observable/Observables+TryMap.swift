//
//  Observables+TryMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

extension Observables {
    
    public struct TryMap<Input, Output>: Observable where Input: Observable {
        
        public typealias Output = Output
        public typealias Failure = Error
        
        public let input: Input
        public let transform: (Input.Output) throws -> Output
        private let _signalConduit: TryTransformSignalConduit<Output, Input.Output, Input.Failure>
        
        public init(input: Input, transform: @escaping (Input.Output) throws -> Output) {
            self.input = input
            self.transform = transform
            self._signalConduit = .init(tryTransform: transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observables.TryMap {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.TryMap<Input, T> {
        return .init(input: input) {
            do {
                return try transform(self.transform($0))
            } catch {
                throw error
            }
        }
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Observables.TryMap<Input, T> {
        return .init(input: input) {
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
        return .init(input: self, transform: transform)
    }
}
