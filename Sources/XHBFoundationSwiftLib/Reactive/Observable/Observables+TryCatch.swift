//
//  Observables+TryCatch.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct TryCatch<Source, New>: Observable
    where Source: Observable, New: Observable, Source.Output == New.Output {
        
        public typealias Output = Source.Output
        public typealias Failure = Error
        
        public let source: Source
        public let handler: (Failure) throws -> New
        
        private let _signalConduit: _TryCatchErrorSignalConduit<Source, New>
        
        public init(source: Source, handler: @escaping (Failure) throws -> New) {
            self.source = source
            self.handler = handler
            self._signalConduit = .init(handler)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.TryCatch {
    
    fileprivate final class _TryCatchErrorSignalConduit<Old: Observable, New: Observable>: ControlSignalConduit<New.Output, New.Failure, Old.Output, Old.Failure> where Old.Failure == Error {
        
        private var newObservable: AnyObservable<New.Output, New.Failure>?
        
        let handler: (Old.Failure) throws -> New
        
        init(_ handler: @escaping (Old.Failure) throws -> New) {
            self.handler = handler
        }
        
        override func receive(failure: Old.Failure) {
            guard let observer = anyObserver else {
                return
            }
            do {
                newObservable = try .init(handler(failure))
                newObservable?.subscribe(observer)
                observer.receive(self)
            } catch {
                observer.receive(.failure(error))
            }
        }
    }
}
