//
//  Observables+FlatMap.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation


extension Observables {
    
    public struct FlatMap<Source: Observable, New: Observable>: Observable where Source.Failure == New.Failure {
        
        public typealias Output = New.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let transform: (Source.Output) -> New
        public let maxObservables: Requirement
        private let _signalConduit: _FlatMapSignalConduit
        
        public init(source: Source, maxObservables: Requirement, transform: @escaping (Source.Output) -> New) {
            self.source = source
            self.maxObservables = maxObservables
            self.transform = transform
            self._signalConduit = .init(source: source, maxObservables: maxObservables, transform: transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.FlatMap {
    
    fileprivate final class _FlatMapSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        var maxObservables: Requirement
        let transform: (Source.Output) -> New
        private var flatObservables: ContiguousArray<AutoCommonSignalConduit<New.Output, New.Failure>>
        private var newObservers: Dictionary<UUID, AnyObserver<New.Output, Failure>>
        
        init(source: Source, maxObservables: Requirement, transform: @escaping (Source.Output) -> New) {
            self.maxObservables = maxObservables
            self.transform = transform
            self.flatObservables = .init()
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(self)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            if maxObservables == .none { return }
            if let maxNumber = maxObservables.number,
                flatObservables.count == maxNumber {
                return
            }
            let newObservable: AnyObservable<New.Output, New.Failure> = .init(transform(value))
            let newConduit: AutoCommonSignalConduit<New.Output, New.Failure> = .init(source: newObservable)
            newObservers.forEach { newConduit.attach(observer: $0.value) }
            flatObservables.append(newConduit)
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            newObservers[id]?.receive(.failure(failure))
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func dispose() {
            super.dispose()
            flatObservables.removeAll()
            newObservers.removeAll()
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
    
    public func flatMap<T, Ob: Observable>(maxObservables: Requirement = .unlimited, _ transform: @escaping (Output) -> Ob)
    -> Observables.FlatMap<Self, Ob> where T == Ob.Output, Failure == Ob.Failure {
        return .init(source: self, maxObservables: maxObservables, transform: transform)
    }
}
