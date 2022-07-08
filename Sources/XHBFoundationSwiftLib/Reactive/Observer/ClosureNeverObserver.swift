//
//  File.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

public struct ClosureNeverObserver<Input>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Never
    
    public let clousre: (Input) -> Void
    
    public init(_ closure: @escaping (Input) -> Void) {
        self.clousre = closure
    }
    
    public func receive(_ input: Input) {
        self.clousre(input)
    }
    
    public func receive(_ completion: Observers.Completion<Never>) {
        
    }
}
