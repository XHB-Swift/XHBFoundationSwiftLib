//
//  Observables+Autoconnect.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

extension Observables {
    
    public class Autoconnect<Source: ConnectableObservable>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        final public let source: Source
        
        public init(source: Source) {
            self.source = source
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            source.subscribe(observer)
            _ = source.connect()
        }
    }
}

extension ConnectableObservable {
    
    public func autoconnect() -> Observables.Autoconnect<Self> {
        return .init(source: self)
    }
}
