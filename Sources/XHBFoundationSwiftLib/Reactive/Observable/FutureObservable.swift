//
//  FutureObservable.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

final public class FutureObservable<Output, Failure>: Observable where Failure: Error {
    
    public typealias Output = Output
    public typealias PromiseClosure = (Result<Output, Failure>) -> Void
    
    private let closure: (PromiseClosure) -> Void
    
    public init(_ fulfillClosure: @escaping (PromiseClosure) -> Void) {
        self.closure = fulfillClosure
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        
    }
}
