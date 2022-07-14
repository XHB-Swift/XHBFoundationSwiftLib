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
            self._signalConduit = .init(maxObservables: maxObservables, transform: transform)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.FlatMap {
    
    fileprivate final class _FlatMapSignalConduit: OneToOneSignalConduit<New.Output, New.Failure, Source.Output, Source.Failure> {
        
        var maxObservables: Requirement
        let transform: (Source.Output) -> New
        private var flatObservables: Dictionary<UUID, BridgePairSignalConduit<New>>
        
        init(maxObservables: Requirement, transform: @escaping (Source.Output) -> New) {
            self.maxObservables = maxObservables
            self.transform = transform
            self.flatObservables = .init()
        }
        
        override func receive(value: Source.Output) {
            if maxObservables == .none { return }
            if let maxNumber = maxObservables.number,
                flatObservables.count == maxNumber {
                return
            }
            guard anyObserver != nil else { return }
            let newObservable: AnyObservable<New.Output, New.Failure> = .init(transform(value))
            let newConduit: BridgePairSignalConduit<New> =
                .init({[weak self] in self?.receiveNew($0, $1)},
                      {[weak self] in self?.receiveNew($0, $1) },
                      {[weak self] in self?.receiveNewCompletion($0)})
            let id: UUID = newConduit.identifier
            newConduit.attach(to: newObservable)
            flatObservables[id] = newConduit
        }
        
        private func receiveNew(_ value: New.Output, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            if maxObservables == .none { return }
            anyObserver?.receive(value)
        }
        
        private func receiveNew(_ failure: New.Failure, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            anyObserver?.receive(.failure(failure))
            flatObservables.removeValue(forKey: id)
        }
        
        private func receiveNewCompletion(_ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            anyObserver?.receive(.finished)
            flatObservables.removeValue(forKey: id)
        }
        
        override func dispose() {
            super.dispose()
            flatObservables.removeAll()
        }
    }
}

extension Observable {
    
    public func flatMap<T, Ob: Observable>(maxObservables: Requirement = .unlimited, _ transform: @escaping (Output) -> Ob)
    -> Observables.FlatMap<Self, Ob> where T == Ob.Output, Failure == Ob.Failure {
        return .init(source: self, maxObservables: maxObservables, transform: transform)
    }
}
