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
        public let handler: (Source.Failure) throws -> New
        
        private let _signalConduit: _TryCatchErrorSignalConduit
        
        public init(source: Source, handler: @escaping (Source.Failure) throws -> New) {
            self.source = source
            self.handler = handler
            self._signalConduit = .init(handler)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, New.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.TryCatch {
    
    fileprivate final class _TryCatchErrorSignalConduit: OneToOneSignalConduit<New.Output, Error, Source.Output, Source.Failure> {
        
        private var newObservable: AnyObservable<New.Output, New.Failure>?
        
        let handler: (Source.Failure) throws -> New
        
        init(_ handler: @escaping (Source.Failure) throws -> New) {
            self.handler = handler
        }
        
        override func receive(value: Source.Output) {
            anyObserver?.receive(value)
        }
        
        override func receiveCompletion() {
            anyObserver?.receive(.finished)
        }
        
        override func receive(failure: Source.Failure) {
            disposeObservable()
            guard let observer = anyObserver else {
                return
            }
            do {
                newObservable = .init(try handler(failure))
                let closure: ClosureObserver<New.Output, New.Failure> =
                    .init({[weak self] in self?.receive(value: $0)  },
                          { _ in  },
                          {[weak self] in self?.receiveCompletion() })
                newObservable?.subscribe(closure)
                observer.receive(self)
            } catch {
                observer.receive(.failure(error))
            }
        }
    }
}

extension Observable {
    
    public func tryCatch<Ob: Observable>(_ handler: @escaping (Failure) throws -> Ob)
    -> Observables.TryCatch<Self, Ob> where Output == Ob.Output {
        return .init(source: self, handler: handler)
    }
    
}
