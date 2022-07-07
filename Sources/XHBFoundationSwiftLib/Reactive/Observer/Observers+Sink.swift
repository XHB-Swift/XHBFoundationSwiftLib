//
//  Observers+Sink.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observers {
    
    final public class Sink<Input, Failure>: Observer where Failure: Error {
        
        public typealias Input = Input
        
        public var receiveValue: (Input) -> Void
        
        public var receiveFailure: (Failure) -> Void
        
        public init(receiveValue: @escaping (Input) -> Void, receiveFailure: @escaping (Failure) -> Void) {
            self.receiveValue = receiveValue
            self.receiveFailure = receiveFailure
        }
        
        public func receive(_ signal: Observers.Signal<Input, Failure>) {
            switch signal {
            case .receiving(let value):
                self.receiveValue(value)
            case .finished:
                break
            case .failure(let error):
                self.receiveFailure(error)
            }
        }
    }
    
}

extension Observable {
    
    public func sink(receiveValue: @escaping (Output) -> Void, receiveFailure: @escaping (Failure) -> Void) {
        let sink: Observers.Sink<Output, Failure> = .init(receiveValue: receiveValue, receiveFailure: receiveFailure)
        subscribe(sink)
    }
}

extension Observable where Failure == Never {
    public func sink(receiveValue: @escaping (Output) -> Void) {
        let sink: Observers.Sink<Output, Failure> = .init(receiveValue: receiveValue, receiveFailure: { $0 })
        subscribe(sink)
    }
}
