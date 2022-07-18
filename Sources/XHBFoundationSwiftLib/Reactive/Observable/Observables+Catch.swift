//
//  Observables+Catch.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

extension Observables {
    
    public struct Catch<Source, New>: Observable
    where Source: Observable, New: Observable, Source.Output == New.Output {
        
        public typealias Output = Source.Output
        public typealias Failure = New.Failure
        
        public let source: Source
        public let handler: (Source.Failure) -> New
        
        private let _signalConduit: _CatchErrorSignalConduit
        
        public init(source: Source, handler: @escaping (Source.Failure) -> New) {
            self.source = source
            self.handler = handler
            self._signalConduit = .init(source: source, handler)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, New.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Catch {
    
    fileprivate final class _CatchErrorSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        private var newConduits: ContiguousArray<AutoCommonSignalConduit<New.Output, New.Failure>>
        private var newObservers: Dictionary<UUID, AnyObserver<New.Output, New.Failure>>
        
        let handler: (Source.Failure) -> New
        
        init(source: Source, _ handler: @escaping (Source.Failure) -> New) {
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
            let newObservable = AnyObservable(handler(failure))
            let newConduit = AutoCommonSignalConduit(source: newObservable)
            newObservers.forEach { newConduit.attach(observer: $0.value) }
            newConduits.append(newConduit)
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func dispose() {
            super.dispose()
            newObservers.removeAll()
            newConduits.removeAll()
        }
        
        override func attach<O>(observer: O) where Source.Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("Should use `attach<O>(observer: O) where New.Output == O.Input, New.Failure == O.Failure, O : Observer`")
        }
        
        func attach<O>(observer: O) where New.Output == O.Input, New.Failure == O.Failure, O : Observer {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}

extension Observable {
    
    public func `catch`<Ob: Observable>(_ handler: @escaping (Failure) -> Ob) -> Observables.Catch<Self, Ob> where Output == Ob.Output {
        return .init(source: self, handler: handler)
    }
}
