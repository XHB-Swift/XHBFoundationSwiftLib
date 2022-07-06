//
//  Observables+Sequence.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observables {
    
    public struct Sequence<Elements, Failure>: Observable where Elements: Swift.Sequence, Failure: Error {
        
        public typealias Output = Elements.Element
        public typealias Failure = Failure
        
        public let sequence: Elements
        
        public init(sequence: Elements) {
            self.sequence = sequence
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Elements.Element == Ob.Input {
            sequence.forEach { observer.receive(.receiving($0)) }
            observer.receive(.finished)
        }
    }
}

extension Observables.Sequence where Failure == Never {
    
    public func min(by areInIncreasingOrder: (Observables.Sequence<Elements, Failure>.Output,
                                              Observables.Sequence<Elements, Failure>.Output) -> Bool)
    -> Optional<Observables.Sequence<Elements, Failure>.Output>.Observable {
        return .init(sequence.min(by: areInIncreasingOrder))
    }
    
    public func max(by areInIncreasingOrder:(Observables.Sequence<Elements, Failure>.Output,
                                             Observables.Sequence<Elements, Failure>.Output) -> Bool)
    -> Optional<Observables.Sequence<Elements, Failure>.Output>.Observable {
        return .init(sequence.max(by: areInIncreasingOrder))
    }
    
    public func first(where predicate: (Observables.Sequence<Elements, Failure>.Output) -> Bool)
    -> Optional<Observables.Sequence<Elements, Failure>.Output>.Observable {
        return .init(sequence.first(where: predicate))
    }
}

extension Observables.Sequence : Equatable where Elements : Equatable {
    
    public static func == (lhs: Observables.Sequence<Elements, Failure>, rhs: Observables.Sequence<Elements, Failure>) -> Bool {
        return lhs.sequence == rhs.sequence
    }
}
