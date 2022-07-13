//
//  Observables+TryFilter.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation


extension Observables {
    
    public struct TryFilter<Input>: Observable where Input: Observable {
        
        public typealias Output = Input.Output
        public typealias Failure = Error
        
        public let input: Input
        public let isIncluded: (Input.Output) throws -> Bool
        private let _signalConduit: TryFilterSignalConduit<Output, Input.Failure>
        
        public init(input: Input, isIncluded: @escaping (Input.Output) throws -> Bool) {
            self.input = input
            self.isIncluded = isIncluded
            self._signalConduit = .init(isIncluded)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Input.Output == Ob.Input {
            self._signalConduit.attach(observer, to: input)
        }
    }
}

extension Observables.TryFilter {
    
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Observables.TryFilter<Input> {
        return .init(input: input) { isIncluded($0) }
    }
    
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Observables.TryFilter<Input> {
        return .init(input: input, isIncluded: isIncluded)
    }
}
