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
            self._signalConduit = .init(source: source, handler)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, New.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.TryCatch {
    
    fileprivate final class _TryCatchErrorSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        private var newConduits: ContiguousArray<AutoCommonSignalConduit<Output, New.Failure>>
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        
        let handler: (Source.Failure) throws -> New
        
        init(source: Source, _ handler: @escaping (Source.Failure) throws -> New) {
            self.handler = handler
            self.newConduits = .init()
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(self)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            newObservers[id]?.receive(value)
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            do {
                let new = try handler(failure)
                let newObservable: AnyObservable<Output, New.Failure>  = .init(new)
                let newConduit: AutoCommonSignalConduit<Output, New.Failure> = .init(source: newObservable)
                let newObserver: ClosureObserver<Output, New.Failure> = .init({ [weak self] value in
                    self?.newObservers.forEach { $0.value.receive(value) }
                },
                                                                              { [weak self] failure in
                    self?.newObservers.forEach { $0.value.receive(.failure(failure)) }
                },
                                                                              { [weak self] in
                    self?.newObservers.forEach { $0.value.receive(.finished) }
                })
                newConduit.attach(observer: newObserver)
                newConduits.append(newConduit)
            } catch {
                newObservers[id]?.receive(.failure(error))
            }
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func attach<O>(observer: O) where Source.Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, New.Output == Ob.Input")
        }
        
        func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}

extension Observable {
    
    public func tryCatch<Ob: Observable>(_ handler: @escaping (Failure) throws -> Ob)
    -> Observables.TryCatch<Self, Ob> where Output == Ob.Output {
        return .init(source: self, handler: handler)
    }
    
}
