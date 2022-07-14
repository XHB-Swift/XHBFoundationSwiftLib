//
//  Observables+ReceiveOn.swift
//  
//
//  Created by 谢鸿标 on 2022/7/15.
//

import Foundation

extension Observables {
    
    public struct ReceiveOn<Source: Observable, Context: RunningContext>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let context: Context
        public let options: Context.Options?
        
        private let _signalConduit: _ReceiveOnSignalConduit
        
        public init(source: Source, context: Context, options: Context.Options?) {
            self.source = source
            self.context = context
            self.options = options
            self._signalConduit = .init(context: context, options: options)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.ReceiveOn {
    
    fileprivate final class _ReceiveOnSignalConduit: PassSignalConduit<Source.Output, Source.Failure> {
        
        let context: Context
        let options: Context.Options?
        
        init(context: Context, options: Context.Options?) {
            self.context = context
            self.options = options
        }
        
        override func receive(value: Source.Output) {
            context.run(options: options) { [weak self] in
                self?.anyObserver?.receive(value)
            }
        }
        
        override func receive(failure: Source.Failure) {
            context.run(options: options) { [weak self] in
                self?.anyObserver?.receive(.failure(failure))
            }
        }
        
        override func receiveCompletion() {
            context.run(options: options) { [weak self] in
                self?.anyObserver?.receive(.finished)
            }
        }
    }
}


extension Observable {
    
    public func receive<R: RunningContext>(on context: R, options: R.Options? = nil) -> Observables.ReceiveOn<Self, R> {
        return .init(source: self, context: context, options: options)
    }
    
}
