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
        
        public init(input: Input, transform: @escaping (Input.Output) throws -> Output) {
            self.input = input
            self.transform = transform
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            let closureObserver: ClosureObserver<Input.Output, Input.Failure> = .init
            {
                do {
                    observer.receive(try transform($0))
                } catch {
                    observer.receive(.failure(error))
                }
            } _:
            {
                observer.receive(.failure($0))
            }
            self.input.subscribe(closureObserver)
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
