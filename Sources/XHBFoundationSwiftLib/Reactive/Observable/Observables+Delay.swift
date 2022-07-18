//
//  Observables+Delay.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation


extension Observables {
    
    public struct Delay<Source: Observable, Context: RunningContext>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let context: Context
        public let options: Context.Options?
        public let interval: Context.Time.Stride
        public let tolerance: Context.Time.Stride?
        private let _signalConduit: _DelaySignalConduit
        
        public init(source: Source,
                    context: Context,
                    interval: Context.Time.Stride,
                    tolerance: Context.Time.Stride?,
                    options: Context.Options? = nil) {
            self.source = source
            self.context = context
            self.interval = interval
            self.tolerance = tolerance
            self.options = options
            self._signalConduit = .init(source:source,
                                        context: context,
                                        interval: interval,
                                        tolerance: tolerance,
                                        options: options)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Delay {
    
    fileprivate final class _DelaySignalConduit: AutoCommonSignalConduit<Output, Failure> {
        
        let context: Context
        let options: Context.Options?
        let interval: Context.Time.Stride
        let tolerance: Context.Time.Stride?
        private var valuesQueue: DataStruct.Queue<Source.Output>
        
        deinit {
            valuesQueue.clear()
        }
        
        init(source: Source,
             context: Context,
             interval: Context.Time.Stride,
             tolerance: Context.Time.Stride?,
             options: Context.Options? = nil) {
            self.context = context
            self.interval = interval
            self.tolerance = tolerance
            self.options = options
            self.valuesQueue = .init()
            super.init(source: source)
        }
        
        override func receiveValue(_ value: Observables.Delay<Source, Context>.Output, _ id: UUID) {
            valuesQueue.enqueue(value)
            let after = context.current.advanced(by: interval)
            context.run(after: after,
                        tolerance: tolerance ?? context.tolerance,
                        options: options) { [weak self] in
                self?.deliveryValue(id)
            }
        }
        
        private func deliveryValue(_ id: UUID) {
            while let value = valuesQueue.dequeue() {
                super.receiveValue(value, id)
            }
        }
    }
}

extension Observable {
    
    public func delay<R: RunningContext>(for interval: R.Time.Stride, tolerance: R.Time.Stride? = nil, context: R, options: R.Options? = nil) -> Observables.Delay<Self, R> {
        return .init(source: self, context: context, interval: interval, tolerance: tolerance, options: options)
    }
}
