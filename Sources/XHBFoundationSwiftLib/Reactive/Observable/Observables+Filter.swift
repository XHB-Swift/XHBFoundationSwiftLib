//
//  Observables+Filter.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct Filter<Input>: Observable where Input: Observable {
        
        public typealias Output = Input.Output
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let isIncluded: (Input.Output) -> Bool
        private let _signalConduit: FilterSignalConduit<Output, Failure>
        
        public init(input: Input, isIncluded: @escaping (Input.Output) -> Bool) {
            self.input = input
            self.isIncluded = isIncluded
            self._signalConduit = .init(isIncluded)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Input.Failure == Ob.Failure, Input.Output == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observables.Filter {
    
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Observables.Filter<Input> {
        return .init(input: input, isIncluded: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Observables.TryFilter<Input> {
        return .init(input: input, isIncluded: isIncluded)
    }
}

extension Observable {
    
    public func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> Observables.Filter<Self> {
        return .init(input: self, isIncluded: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: @escaping (Self.Output) throws -> Bool) -> Observables.TryFilter<Self> {
        return .init(input: self, isIncluded: isIncluded)
    }
}
