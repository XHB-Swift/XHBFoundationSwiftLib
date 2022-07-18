//
//  Observables+CompactMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct CompactMap<Source: Observable, Output>: Observable {
        
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let transform: (Source.Output) -> Output?
        private let _signalConduit: _CompactMapSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Output) -> Output?) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(source:source, transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.CompactMap {
    
    fileprivate final class _CompactMapSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        let transform: (Source.Output) -> Output?
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Source.Failure>>
        
        init(source: Source, _ transform: @escaping (Source.Output) -> Output?) {
            self.transform = transform
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(self)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            guard let v = transform(value) else { return }
            newObservers[id]?.receive(v)
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            newObservers[id]?.receive(.failure(failure))
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func attach<O>(observer: O) where Source.Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("Should use `attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input`")
        }
        
        func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}

extension Observables.CompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Observables.CompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = self.transform($0) else { return nil }
            return transform(v)
        })
    }
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Observables.CompactMap<Source, T> {
        return .init(source: source, transform: {
            guard let v = self.transform($0) else { return nil }
            return transform(v)
        })
    }
}

extension Observable {
    
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Observables.CompactMap<Self, T> {
        return .init(source: self, transform: transform)
    }
    
    
}
