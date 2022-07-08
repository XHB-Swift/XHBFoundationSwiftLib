//
//  JustObservable.swift
//  
//
//  Created by 谢鸿标 on 2022/7/7.
//

import Foundation

public struct JustObservable<Output>: Observable {
    
    public typealias Output = Output
    public typealias Failure = Never
    
    public let output: Output
    
    public init(output: Output) {
        self.output = output
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Never == Ob.Failure, Output == Ob.Input {
        observer.receive(output)
        observer.receive(.finished)
    }
}

extension JustObservable : Equatable where Output : Equatable {
    
    public static func == (lhs: JustObservable, rhs: JustObservable) -> Bool {
        return lhs.output == rhs.output
    }
    
}
