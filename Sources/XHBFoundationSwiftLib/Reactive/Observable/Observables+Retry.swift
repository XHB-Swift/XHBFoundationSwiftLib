//
//  Observables+Retry.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation


extension Observables {
    
    public struct Retry<Input>: Observable where Input: Observable {
        
        public typealias Output = Input.Output
        public typealias Failure = Input.Failure
        
        public let input: Input
        public let retries: Int?
        
        private let _manager: _RetryManager<Output>
        
        public init(input: Input, retries: Int?) {
            self.input = input
            self.retries = retries
            self._manager = .init()
        }
     
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._manager.attach(observer)
            self.input.subscribe(self._manager.nObserver)
        }
    }
}

extension Observables.Retry {
    
    fileprivate final class _RetryManager<Output>: SignalConduit {
        
        private var retries: Int?
        private var observer: AnyObserver<Output, Failure>?
        
        var nObserver: ClosureObserver<Output, Failure> {
            return .init({[weak self] in self?.receive($0)},
                         {[weak self] in self?.receive($0)})
        }
        
        private func receive(_ value: Output) {
            lock.lock()
            defer { lock.unlock() }
            self.observer?.receive(value)
        }
        
        private func receive(_ failure: Failure) {
            lock.lock()
            defer { lock.unlock() }
            guard let retries = retries else {
                return
            }
            if retries == 0 { return }
        }
        
        func attach<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
    }
}
