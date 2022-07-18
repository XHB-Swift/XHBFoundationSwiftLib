//
//  Observables+MapError.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation


extension Observables {
    
    public struct MapError<Source: Observable, Failure: Error>: Observable {
        
        public typealias Output = Source.Output
        
        public let source: Source
        public let transform: (Source.Failure) -> Failure
        private let _signalConduit: _MapErrorSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Failure) -> Failure) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(source: source, transform)
        }
        
        public init(source: Source, _ map: @escaping (Source.Failure) -> Failure) {
            self.source = source
            self.transform = map
            self._signalConduit = .init(source:source, map)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.MapError {
    
    fileprivate final class _MapErrorSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        let transform: (Source.Failure) -> Failure
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        
        init(source: Source, _ transform: @escaping (Source.Failure) -> Failure) {
            self.transform = transform
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(self)
        }
        
        override func receiveValue(_ value: Observables.MapError<Source, Failure>.Output, _ id: UUID) {
            newObservers[id]?.receive(value)
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            let newError = transform(failure)
            newObservers[id]?.receive(.failure(newError))
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func attach<O>(observer: O) where Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("Should use `attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer`")
        }
        
        func attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}
