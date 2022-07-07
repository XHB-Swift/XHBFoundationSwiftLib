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
    
    private var output: Output?
    private var failure: Failure?
    private var anyObservers: ContiguousArray<AnyObserver<Output, Failure>> = .init()
    
    public init(_ fulfillClosure: @escaping (@escaping PromiseClosure) -> Void) {
        fulfillClosure({ [weak self] result in
            switch result {
            case .success(let value):
                self?.output = value
                self?.observerOutput(value)
            case .failure(let error):
                self?.failure = error
                self?.observerReceive(error)
            }
        })
    }
    
    public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
        anyObservers.append(.init(observer))
        if let value = output {
            observerOutput(value)
        } else if let failure = failure {
            observerReceive(failure)
        }
    }
    
    private func observerOutput(_ output: Output) {
        var ob = anyObservers.first
        while ob != nil {
            ob?.receive(.receiving(output))
            _ = anyObservers.removeFirst()
            ob = anyObservers.first
        }
    }
    
    private func observerReceive(_ failure: Failure) {
        var ob = anyObservers.first
        while ob != nil {
            ob?.receive(.failure(failure))
            _ = anyObservers.removeFirst()
            ob = anyObservers.first
        }
    }
}
