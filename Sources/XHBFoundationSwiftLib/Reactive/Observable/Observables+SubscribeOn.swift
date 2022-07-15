//
//  Observables+SubscribeOn.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation


extension Observables {
    
    public struct SubscribeOn<Source: Observable, Context: RunningContext>: Observable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let context: Context
        public let options: Context.Options?
        private let _signalConduit: PassSignalConduit<Source.Output, Source.Failure>
        
        public init(source: Source, context: Context, options: Context.Options?) {
            self.source = source
            self.context = context
            self.options = options
            self._signalConduit = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            context.run(options: options) {
                self._signalConduit.attach(observer, to: source)
            }
        }
    }
}

extension Observable {
    
    public func subscribe<R: RunningContext>(on context: R, options: R.Options? = nil) -> Observables.SubscribeOn<Self, R> {
        return .init(source: self, context: context, options: options)
    }
    
}
