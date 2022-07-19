//
//  Observables+Share.swift
//  
//
//  Created by xiehongbiao on 2022/7/18.
//

import Foundation


extension Observables {
    
    final public class Share<Source: Observable>: Observable, Equatable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        private let _signalConduit: AutoCommonSignalConduit<Output, Failure>
        
        public init(source: Source) {
            self.source = source
            self._signalConduit = .init(source: source)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
        
        public static func == (lhs: Share<Source>, rhs: Share<Source>) -> Bool {
            return lhs === rhs
        }
    }
}

extension Observable {
    
    public func share() -> Observables.Share<Self> {
        return .init(source: self)
    }
}
