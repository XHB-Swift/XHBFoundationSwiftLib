//
//  Result+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/8.
//

import Foundation

extension Result {
    
    public var observation: Result<Success, Failure>.Observation {
        return .init(self)
    }
    
    public struct Observation: Observable {
        
        public typealias Output = Success
        
        public let result: Result<Output, Failure>
        
        public init(_ result: Result<Output, Failure>) {
            self.result = result
        }
        
        public init(_ output: Output) {
            self.result = .success(output)
        }
        
        public init(_ failure: Failure) {
            self.result = .failure(failure)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Success == Ob.Input {
            switch self.result {
            case .success(let value):
                observer.receive(value)
            case .failure(let error):
                observer.receive(.failure(error))
            }
        }
    }
    
}
