//
//  Observables+Retry.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation


extension Observables {
    
    public struct Retry<Source>: Observable where Source: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let retries: Int?
        
        private let _signalConduit: _RetrySignalConduit<Output>
        
        public init(source: Source, retries: Int?) {
            self.source = source
            self.retries = retries
            self._signalConduit = .init(retries: retries)
        }
     
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.bind(observer: observer, to: source)
        }
    }
}

extension Observables.Retry {
    
    fileprivate final class _RetrySignalConduit<Output>: SignalConduit {
        
        private var retries: Int?
        private var observable: AnyObservable<Output, Failure>?
        private var observer: AnyObserver<Output, Failure>?
        
        init(retries: Int?) {
            super.init()
            self.retries = retries
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
                retryHandle()
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
            let nObserver: ClosureObserver<Output, Failure> = .init({[weak self] in self?.receive($0)},
                                                                    {[weak self] in self?.receive($0)})
            self.observable?.subscribe(nObserver)
            self.observer?.receive(self)
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
        return .init(source: self, retries: retries)
    }
    
}
