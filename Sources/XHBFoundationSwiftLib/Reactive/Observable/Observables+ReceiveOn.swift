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
            self._signalConduit = .init(source: source, context: context, options: options)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.ReceiveOn {
    
    fileprivate final class _ReceiveOnSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        let context: Context
        let options: Context.Options?
        
        init(source:Source, context: Context, options: Context.Options?) {
            self.context = context
            self.options = options
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            context.run(options: options) {
                super.receiveSignal(signal, id)
            }
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            context.run(options: options) {
                super.receiveValue(value, id)
            }
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            context.run(options: options) {
                super.receiveFailure(failure, id)
            }
        }
        
        override func receiveCompletion(_ id: UUID) {
            context.run(options: options) {
                super.receiveCompletion(id)
            }
        }
    }
}


extension Observable {
    
    public func receive<R: RunningContext>(on context: R, options: R.Options? = nil) -> Observables.ReceiveOn<Self, R> {
        return .init(source: self, context: context, options: options)
    }
    
}
