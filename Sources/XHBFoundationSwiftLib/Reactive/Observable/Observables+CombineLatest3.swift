//
//  Observables+CombineLatest3.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension Observables {
    
    public struct CombineLatest3<A, B, C>: Observable
    where A: Observable, B: Observable, C: Observable, A.Failure == B.Failure, B.Failure == C.Failure {
        
        public typealias Output = (A.Output, B.Output, C.Output)
        public typealias Failure = A.Failure
        
        public let a: A

        public let b: B

        public let c: C
        
        private let _valueBuffer: _CombineLatest3ValueBuffer<A.Output, B.Output, C.Output>

        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
            self._valueBuffer = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, A.Failure == Ob.Failure, (A.Output, B.Output, C.Output) == Ob.Input {
            self._valueBuffer.attach(observer)
            self.a.subscribe(self._valueBuffer.aObserver)
            self.b.subscribe(self._valueBuffer.bObserver)
            self.c.subscribe(self._valueBuffer.cObserver)
        }
    }
}

extension Observables.CombineLatest3 {
    
    fileprivate final class _CombineLatest3ValueBuffer<A, B, C>: SignalConduit {
        
        private var aValue: A?
        private var bValue: B?
        private var cValue: C?
        
        private var observer: AnyObserver<(A, B, C), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({[weak self] in self?.updateA($0) },
                         {[weak self] in self?.emitFailure($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({[weak self] in self?.updateB($0) },
                         {[weak self] in self?.emitFailure($0) })
        }
        
        var cObserver: ClosureObserver<C, Failure> {
            return .init({[weak self] in self?.updateC($0) },
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
        
        private func updateC(_ value: C) {
            lock.lock()
            defer { lock.unlock() }
            cValue = value
            send()
        }
        
        override func send() {
            guard requirement > .none,
                  let a = aValue,
                  let b = bValue,
                  let c = cValue else { return }
            observer?.receive((a,b,c))
        }
        
        override func dispose() {
            aValue = nil
            bValue = nil
            cValue = nil
            observer = nil
        }
        
        func attach<O: Observer>(_ observer: O) where O.Input == (A, B, C), O.Failure == Failure {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
    }
    
}

extension Observables.CombineLatest3: Equatable where A: Equatable, B: Equatable, C: Equatable {
    
    public static func == (lhs: Observables.CombineLatest3<A, B, C>, rhs: Observables.CombineLatest3<A, B, C>) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
    }
}

extension Observable {
    
    public func combineLatest<Ob1: Observable, Ob2: Observable>(_ ob1: Ob1, _ ob2: Ob2)
    -> Observables.CombineLatest3<Self, Ob1, Ob2> where Self.Failure == Ob1.Failure, Ob1.Failure == Ob2.Failure {
        return .init(self, ob1, ob2)
    }
    
    public func combineLatest<Ob1: Observable, Ob2: Observable, T>(_ ob1: Ob1,
                                                                   _ ob2: Ob2,
                                                                   _ transform: @escaping (Self.Output, Ob1.Output, Ob2.Output) -> T)
    -> Observables.Map<Observables.CombineLatest3<Self, Ob1, Ob2>, T> where Self.Failure == Ob1.Failure, Ob1.Failure == Ob2.Failure {
        return .init(input: self.combineLatest(ob1, ob2), transform: transform)
    }
    
}
