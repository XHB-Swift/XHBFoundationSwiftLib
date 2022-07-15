//
//  ClosureObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

public typealias ClosureNeverObserver<Input> = ClosureObserver<Input, Never>

public struct ClosureObserver<Input, Failure: Error>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Failure
    
    public let identifier: UUID = .init()
    
    public let clousre: (Input) -> Void
    public let failure: (Failure) -> Void
    public var completion: (() -> Void)?
    
    public init(_ closure: @escaping (Input) -> Void,
                _ failure: @escaping (Failure) -> Void,
                _ completion: (() -> Void)? = nil) {
        self.clousre = closure
        self.failure = failure
        self.completion = completion
    }
    
    public func receive(_ signal: Signal) {
        signal.request(.unlimited)
    }
    
    public func receive(_ signal: Observers.Completion<Failure>) {
        switch signal {
        case .finished:
            self.completion?()
        case .failure(let error):
            self.failure(error)
        }
    }
    
    public func receive(_ input: Input) {
        self.clousre(input)
    }
}

extension ClosureObserver where Failure == Never {
    
    public init(_ closure: @escaping (Input) -> Void, _ completion: (() -> Void)? = nil) {
        self.clousre = closure
        self.failure = { _ in }
        self.completion = completion
    }
}
