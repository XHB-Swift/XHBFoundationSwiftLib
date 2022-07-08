//
//  Observables+Map.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct Map<Input, Output>: Observable where Input: Observable {
        
        public typealias Output = Output
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let transform: (Input.Output) -> Output
        
        public init(input: Input, transform: @escaping (Input.Output) -> Output) {
            self.input = input
            self.transform = transform
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Output == Ob.Input {
            let closureOb: ClosureObserver<Input.Output, Failure> = .init
            { observer.receive(transform($0)) } _: { observer.receive(.failure($0)) }
            input.subscribe(closureOb)
        }
    }
}

extension Observables.Map {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.Map<Input, T> {
        return .init(input: input) { transform(self.transform($0)) }
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
    
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Observables.Map<Self, T> {
        return .init(input: self, transform: transform)
    }
    
    public func replaceNil<T>(with output: T) -> Observables.Map<Self, T> where Self.Output == T? {
        return .init(input: self, transform: {  $0 ?? output })
    }
}
