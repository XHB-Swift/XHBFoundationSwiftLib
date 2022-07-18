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
        
        public let identifier: UUID = .init()
        
        public var receiveValue: (Input) -> Void
        
        public var receiveCompletion: (Observers.Completion<Failure>) -> Void
        
        private var signal: Signal?
        
        public init(receiveValue: @escaping (Input) -> Void, receiveCompletion: @escaping (Observers.Completion<Failure>) -> Void) {
            self.receiveValue = receiveValue
            self.receiveCompletion = receiveCompletion
        }
        
        public func receive(_ signal: Signal) {
            self.signal = signal
            self.signal?.request(.unlimited)
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
            signal?.cancel()
            signal = nil
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self), Signal = \(String(describing: signal))")
            #endif
            cancel()
        }
    }
    
}

extension Observable {
    
    public func sink(receiveValue: @escaping (Output) -> Void, completion: @escaping (Observers.Completion<Failure>) -> Void) -> AnyCancellable {
        let sink: Observers.Sink<Output, Failure> = .init(receiveValue: receiveValue, receiveCompletion: completion)
        subscribe(sink)
        return .init(sink)
    }
}

extension Observable where Failure == Never {
    
    public func sink(receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        return sink(receiveValue: receiveValue, completion: { _ in })
    }
}
