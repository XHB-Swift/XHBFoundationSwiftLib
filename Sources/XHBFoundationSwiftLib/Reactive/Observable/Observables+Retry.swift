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
            self._manager.bind(observer: observer, to: input)
        }
    }
}

extension Observables.Retry {
    
    fileprivate final class _RetryManager<Output>: SignalConduit {
        
        private var retries: Int?
        private var observable: AnyObservable<Output, Failure>?
        private var observer: AnyObserver<Output, Failure>?
        
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
            if retries == 0 {
                self.observer?.receive(.failure(failure))
                return
            }
            self.retries = retries - 1
            retryHandle()
        }
        
        private func retryHandle() {
            self.observer?.receive(self)
            let nObserver: ClosureObserver<Output, Failure> = .init({[weak self] in self?.receive($0)},
                                                                    {[weak self] in self?.receive($0)})
            self.observable?.subscribe(nObserver)
        }
        
        func bind<Ob: Observable, O: Observer>(observer: O, to observable: Ob)
        where Output == Ob.Output, Failure == Ob.Failure, Ob.Output == O.Input, Ob.Failure == O.Failure {
            self.observer = .init(observer)
            self.observable = .init(observable)
            retryHandle()
        }
        
        override func dispose() {
            observer = nil
            observable = nil
        }
    }
}

extension Observable {
    
    public func retry(_ retries: Int) -> Observables.Retry<Self> {
        return .init(input: self, retries: retries)
    }
    
}
