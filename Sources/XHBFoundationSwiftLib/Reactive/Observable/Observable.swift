//
//  Observable.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

public protocol Observable {
    
    associatedtype Output
    associatedtype Failure: Error
    
    func subscribe<Ob: Observer>(_ observer: Ob) where Output == Ob.Input, Failure == Ob.Failure
}

extension Optional {
    
    public struct Observable: XHBFoundationSwiftLib.Observable {
        
        public typealias Output = Wrapped
        public typealias Failure = Never
        
        public let output: Optional<Wrapped>.Observable.Output?
        
        public init(_ output: Optional<Wrapped>.Observable.Output?) {
            self.output = output
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Never == Ob.Failure, Wrapped == Ob.Input {
            guard let wrapped = output else { return }
            observer.receive(wrapped)
        }
    }
}
