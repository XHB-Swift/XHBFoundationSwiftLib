//
//  Observers+Sink.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observers {
    
    final public class Sink<Input, Failure>: Observer, Cancellable where Failure: Error {
        
        public typealias Input = Input
        
        public var receiveValue: (Input) -> Void
        
        public var receiveCompletion: (Observers.Completion<Failure>) -> Void
        
        public init(receiveValue: @escaping (Input) -> Void, receiveCompletion: @escaping (Observers.Completion<Failure>) -> Void) {
            self.receiveValue = receiveValue
            self.receiveCompletion = receiveCompletion
        }
        
        public func receive(_ input: Input) {
            self.receiveValue(input)
        }
        
        public func receive(_ completion: Observers.Completion<Failure>) {
            switch completion {
            case .finished:
                self.receiveCompletion(.finished)
            case .failure(let error):
                self.receiveCompletion(.failure(error))
            }
        }
        
        public func cancel() {
            //receiveValue = nil
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
            cancel()
        }
    }
    
}

extension Observable {
    
    public func sink(receiveValue: @escaping (Output) -> Void, completion: @escaping (Observers.Completion<Failure>) -> Void) {
        let sink: Observers.Sink<Output, Failure> = .init(receiveValue: receiveValue, receiveCompletion: completion)
        subscribe(sink)
    }
}

extension Observable where Failure == Never {
    public func sink(receiveValue: @escaping (Output) -> Void) {
        let sink: Observers.Sink<Output, Failure> = .init(receiveValue: receiveValue, receiveCompletion: { _ in })
        subscribe(sink)
    }
}
