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
            self._valueBuffer.observer = .init(observer)
            self.a.subscribe(self._valueBuffer.aObserver)
            self.b.subscribe(self._valueBuffer.bObserver)
            self.c.subscribe(self._valueBuffer.cObserver)
        }
    }
}

extension Observables.Zip3 {
    
    fileprivate final class _Zip3ValueBuffer<A,B,C> {
        
        private var aValues: ContiguousArray<A>
        private var bValues: ContiguousArray<B>
        private var aIndex: Int
        private var bIndex: Int
        private let lock: DispatchSemaphore = .init(value: 1)
        
        var observer: AnyObserver<(A,B,C), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({ [weak self] in self?.aValues.append($0) }, { [weak self] in self?.emit($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({ [weak self] in self?.bValues.append($0) }, { [weak self] in self?.emit($0) })
        }
        
        var cObserver: ClosureObserver<C, Failure> {
            return .init({ [weak self] in self?.emitC($0) }, { [weak self] in self?.emit($0) })
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
        
        init() {
            aIndex = -1
            bIndex = -1
            aValues = .init()
            bValues = .init()
        }
        
        private func emit(_ failure: Failure) {
            self.observer?.receive(.failure(failure))
        }
        
        private func emitC(_ value: C) {
            if aValues.isEmpty || bValues.isEmpty { return }
            aIndex += 1
            bIndex += 1
            let aRange = 0..<aValues.count
            let bRange = 0..<bValues.count
            if !aRange.contains(aIndex) || !bRange.contains(bIndex) { return }
            let a = aValues[aIndex]
            let b = bValues[bIndex]
            self.observer?.receive((a,b,value))
            aValues.remove(at: aIndex)
            bValues.remove(at: bIndex)
            aIndex -= 1
            bIndex -= 1
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
