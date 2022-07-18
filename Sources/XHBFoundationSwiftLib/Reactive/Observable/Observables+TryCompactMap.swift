//
//  Observables+TryCompactMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct TryCompactMap<Source: Observable, Output>: Observable {
        
        public typealias Failure = Error
        
        public let source: Source
        public let transform: (Source.Output) throws -> Output?
        private let _signalConduit: _TryCompactMapSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Output) throws -> Output?) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(source:source, transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.TryCompactMap {
    
    fileprivate final class _TryCompactMapSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        let transform: (Source.Output) throws -> Output?
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        
        init(source: Source, _ transform: @escaping (Source.Output) throws -> Output?) {
            self.transform = transform
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(signal)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            do {
                guard let v = try transform(value) else { return }
                newObservers[id]?.receive(v)
            } catch {
                newObservers[id]?.receive(.failure(error))
            }
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            cancel()
            newObservers[id]?.receive(.failure(failure))
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func dispose() {
            newObservers.removeAll()
        }
        
        override func attach<O>(observer: O) where Source.Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer")
        }
        
        func attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}

extension Observables.TryCompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Observables.TryCompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = try self.transform($0) else { return nil }
            return try transform(v)
        })
    }
}

extension Observable {
    
    public func tryCompactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Observables.TryCompactMap<Self, T> {
        return .init(source: self, transform: transform)
    }
}
