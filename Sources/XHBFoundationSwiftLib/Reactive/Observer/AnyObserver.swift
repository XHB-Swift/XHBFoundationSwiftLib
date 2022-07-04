//
//  AnyObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

open class AnyObserver<Input, Failure: Error>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Failure
    
    public typealias OnInput = (Input) -> Void
    public typealias OnOccur = (Failure) -> Void
    
    private var inputClosure: OnInput
    private var occurClosure: OnOccur
    
    public init<O: Observer>(_ observer: O) where O.Input == Input, O.Failure == Failure {
        self.inputClosure = observer.receive(_:)
        self.occurClosure = observer.receive(_:)
    }
    
    public func receive(_ input: Input) {
        self.inputClosure(input)
    }
    
    public func receive(_ failure: Failure) {
        self.occurClosure(failure)
    }
}
