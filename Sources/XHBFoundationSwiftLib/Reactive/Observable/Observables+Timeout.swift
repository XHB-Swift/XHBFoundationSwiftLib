//
//  Observables+Timeout.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation


extension Observables {
    
    public struct Timeout<Source: Observable, Context: RunningContext>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let context: Context
        public let interval: Context.Time.Stride
        public let options: Context.Options?
        public let customError: (() -> Failure)?
        private let _signalConduit: _TimeoutSignalConduit
        
        public init(source: Source,
                    context: Context,
                    interval: Context.Time.Stride,
                    options: Context.Options?,
                    customError: (() -> Failure)?) {
            self.source = source
            self.context = context
            self.interval = interval
            self.options = options
            self.customError = customError
            self._signalConduit = .init(source: source, context: context, interval: interval, options: options, customError: customError)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Timeout {
    
    fileprivate final class _TimeoutSignalConduit: AutoCommonSignalConduit<Output, Failure> {
        
        let context: Context
        let interval: Context.Time.Stride
        let options: Context.Options?
        let customError: (() -> Failure)?
        private var isSetupTimeoutAction = false
        private var timeout = false
        
        init(source: Source, context: Context, interval: Context.Time.Stride, options: Context.Options?, customError: (() -> Failure)?) {
            self.context = context
            self.interval = interval
            self.options = options
            self.customError = customError
            super.init(source: source)
        }
        
        override func receiveValue(_ value: Observables.Timeout<Source, Context>.Output, _ id: UUID) {
            if timeout { return }
            context.run {
                super.receiveValue(value, id)
            }
        }
        
        private func setupTimeoutActionIfPossbile() {
            lock.lock()
            defer { lock.unlock() }
            if isSetupTimeoutAction { return }
            isSetupTimeoutAction = true
            let current = context.current
            let after = current.advanced(by: interval)
            context.run(after: after, tolerance: context.tolerance, options: options) {
                self.lock.lock()
                self.timeout = true
                self.lock.unlock()
                if let customError = self.customError?() {
                    self.receiveFailure(customError)
                } else {
                    self.receiveCompletion()
                }
            }
        }
        
        override func attach<O>(observer: O) where Observables.Timeout<Source, Context>.Output == O.Input, Observables.Timeout<Source, Context>.Failure == O.Failure, O : Observer {
            context.run {
                super.attach(observer: observer)
            }
            setupTimeoutActionIfPossbile()
        }
    }
}

extension Observable {
    
    public func timeout<R: RunningContext>(_ interval: R.Time.Stride, context: R, options: R.Options? = nil, customError: (() -> Failure)? = nil) -> Observables.Timeout<Self, R> {
        return .init(source: self, context: context, interval: interval, options: options, customError: customError)
    }
    
}
