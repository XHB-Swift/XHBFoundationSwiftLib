//
//  ClosureObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

public struct ClosureObserver<Input, Failure: Error>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Failure
    
    public let clousre: (Input) -> Void
    public let failure: (Failure) -> Void
    
    public init(_ closure: @escaping (Input) -> Void,
                _ failure: @escaping (Failure) -> Void) {
        self.clousre = closure
        self.failure = failure
    }
    
    public func receive(_ signal: Observers.Signal<Input, Failure>) {
        switch signal {
        case .finished:
            break
        case .receiving(let value):
            self.clousre(value)
        case .failure(let error):
            self.failure(error)
        }
    }
}
