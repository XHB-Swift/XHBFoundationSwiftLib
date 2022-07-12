//
//  Observables+Zip3.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

extension Observables {
    
    public struct Zip3<A, B, C>: Observable
    where A: Observable, B: Observable, C: Observable, A.Failure == B.Failure, B.Failure == C.Failure {
        
        public typealias Output = (A.Output, B.Output, C.Output)
        public typealias Failure = A.Failure
        
        public let a: A
        public let b: B
        public let c: C
        
        private let _valueBuffer: _Zip3ValueBuffer<A.Output,B.Output,C.Output>
        
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

extension Observables.Zip3 {
    
    fileprivate final class _Zip3ValueBuffer<A,B,C>: SignalConduit {
        
        private var aValues: DataStruct.Queue<A>
        private var bValues: DataStruct.Queue<B>
        private var cValue: C?
        
        private var observer: AnyObserver<(A,B,C), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({ [weak self] in self?.appendA($0) }, { [weak self] in self?.emit($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({ [weak self] in self?.appendB($0) }, { [weak self] in self?.emit($0) })
        }
        
        var cObserver: ClosureObserver<C, Failure> {
            return .init({ [weak self] in self?.emitC($0) }, { [weak self] in self?.emit($0) })
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
        
        override init() {
            aValues = .init()
            bValues = .init()
        }
        
        private func emit(_ failure: Failure) {
            self.observer?.receive(.failure(failure))
        }
        
        private func appendA(_ value: A) {
            aValues.enqueue(value)
        }
        
        private func appendB(_ value: B) {
            bValues.enqueue(value)
        }
        
        private func emitC(_ value: C) {
            cValue = value
            send()
        }
        
        override func send() {
            if aValues.isEmpty || bValues.isEmpty { return }
            while requirement > .none,
                  let a = aValues.peek(),
                  let b = bValues.peek(),
                  let c = cValue {
                self.observer?.receive((a,b,c))
                _ = aValues.dequeue()
                _ = bValues.dequeue()
                cValue = nil
            }
        }
        
        override func dispose() {
            aValues.clear()
            bValues.clear()
            cValue = nil
            observer = nil
        }
        
        func attach<O: Observer>(_ observer: O) where O.Input == (A, B, C), O.Failure == Failure {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
    }
}

extension Observable {
    
    public func zip<B: Observable, C: Observable>(_ b: B, _ c: C)
    -> Observables.Zip3<Self, B, C> where Self.Failure == B.Failure, B.Failure == C.Failure {
        return .init(self, b, c)
    }
    
    public func zip<B: Observable, C: Observable, T>(_ b: B, _ c: C, _ transform: @escaping (Self.Output, B.Output, C.Output) -> T)
    -> Observables.Map<Observables.Zip3<Self, B, C>, T> where Self.Failure == B.Failure, B.Failure == C.Failure {
        return zip(b, c).map(transform)
    }
}
