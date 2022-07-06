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
    
    public func receive(_ signal: Observers.Signal<Input, Never>) {
        switch signal {
        case .receiving(let value):
            self.clousre(value)
        case .failure(_), .finished:
            break
        }
    }
}
