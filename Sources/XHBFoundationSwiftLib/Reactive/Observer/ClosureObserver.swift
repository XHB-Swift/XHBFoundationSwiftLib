//
//  ClosureObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

public struct ClosureObserver<Input>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Never
    
    public let clousre: (Input) -> Void
    
    public init(_ closure: @escaping (Input) -> Void) {
        self.clousre = closure
    }
    
    public func receive(_ input: Input) {
        self.clousre(input)
    }
    
    public func receive(_ failure: Never) {
        
    }
}
