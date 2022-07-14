//
//  Observables+CombineLatest.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension Observables {
    
    public struct CombineLatest<A, B>: Observable
    where A: Observable, B: Observable, A.Failure == B.Failure {
        
        public typealias Output = (A.Output, B.Output)
        
        public typealias Failure = A.Failure
        
        public let a: A

        public let b: B
        
        private let _valueBuffer: _CombineLatestValueBuffer<A.Output, B.Output>
        
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
            self._valueBuffer = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, A.Failure == Ob.Failure, (A.Output, B.Output) == Ob.Input {
            self._valueBuffer.attach(observer)
            self.a.subscribe(self._valueBuffer.aObserver)
            self.b.subscribe(self._valueBuffer.bObserver)
        }
    }
}

extension Observables.CombineLatest {
    
    fileprivate final class _CombineLatestValueBuffer<A, B>: SignalConduit {
        
        private var aValue: A?
        private var bValue: B?
        
        private var observer: AnyObserver<(A, B), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({[weak self] in self?.updateA($0) },
                         {[weak self] in self?.emitFailure($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({[weak self] in self?.updateB($0) },
                         {[weak self] in self?.emitFailure($0) })
        }
        
        private func updateA(_ value: A) {
            lock.lock()
            defer { lock.unlock() }
            aValue = value
            send()
        }
        
        private func emitFailure(_ failure: Failure) {
            lock.lock()
            defer { lock.unlock() }
            observer?.receive(.failure(failure))
        }
        
        private func updateB(_ value: B) {
            lock.lock()
            defer { lock.unlock() }
            bValue = value
            send()
        }
        
        override func send() {
            guard requirement > .none,
                  let a = aValue,
                  let b = bValue else { return }
            observer?.receive((a,b))
        }
        
        override func dispose() {
            aValue = nil
            bValue = nil
            observer = nil
        }
        
        func attach<O: Observer>(_ observer: O) where O.Input == (A, B), O.Failure == Failure {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
    }
}

extension Observables.CombineLatest: Equatable where A: Equatable, B: Equatable {
    
    public static func == (lhs: Observables.CombineLatest<A, B>, rhs: Observables.CombineLatest<A, B>) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension Observable {
    
    public func combineLatest<Ob: Observable>(_ other: Ob) -> Observables.CombineLatest<Self,Ob> where Self.Failure == Ob.Failure {
        return .init(self, other)
    }
    
    public func combineLatest<Ob: Observable, T>(_ other: Ob, transform: @escaping (Self.Output, Ob.Output) -> T)
    -> Observables.Map<Observables.CombineLatest<Self,Ob>, T> where Self.Failure == Ob.Failure {
        return .init(source: self.combineLatest(other), transform: transform)
    }
}
