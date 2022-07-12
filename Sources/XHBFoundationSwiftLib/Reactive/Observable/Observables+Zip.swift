//
//  Observables+Zip.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation


extension Observables {
    
    public struct Zip<A, B>: Observable where A: Observable, B: Observable, A.Failure == B.Failure {
        
        public typealias Output = (A.Output, B.Output)
        public typealias Failure = A.Failure
        
        public let a: A
        public let b: B
        
        private let _valueBuffer: _ZipValueBuffer<A.Output, B.Output>
        
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

extension Observables.Zip {
    
    fileprivate final class _ZipValueBuffer<A, B>: SignalConduit {
        
        private var aValues: DataStruct.Queue<A>
        private var bValue: B?
        
        private var observer: AnyObserver<(A ,B), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({ [weak self] in self?.appendA($0) },
                         { [weak self] in self?.emit($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({ [weak self] in self?.emitB($0) },
                         { [weak self] in self?.emit($0) })
        }
        
        override init() { aValues = .init() }
        
        private func emit(_ failure: Failure) {
            lock.lock()
            defer { lock.unlock() }
            observer?.receive(.failure(failure))
        }
        
        private func appendA(_ value: A) {
            lock.lock()
            defer { lock.unlock() }
            aValues.enqueue(value)
        }
        
        private func emitB(_ value: B) {
            lock.lock()
            defer { lock.unlock() }
            bValue = value
            send()
        }
        
        override func send() {
            if aValues.isEmpty { return }
            while requirement > .none,
                  let a = aValues.peek(),
                  let b = bValue {
                observer?.receive((a, b))
                _ = aValues.dequeue()
                bValue = nil
            }
        }
        
        override func dispose() {
            aValues.clear()
            bValue = nil
            observer = nil
        }
        
        func attach<O: Observer>(_ observer: O) where O.Input == (A, B), O.Failure == Failure {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
    }
}

extension Observables.Zip: Equatable where A: Equatable, B: Equatable {
    
    public static func == (lhs: Observables.Zip<A,B>, rhs: Observables.Zip<A,B>) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension Observable {
    
    public func zip<Ob: Observable>(_ other: Ob)
    -> Observables.Zip<Self, Ob> where Ob.Failure == Self.Failure {
        return .init(self, other)
    }
    
    public func zip<Ob: Observable, T>(_ other: Ob, _ transform: @escaping (Self.Output, Ob.Output) -> T)
    -> Observables.Map<Observables.Zip<Self, Ob>, T>
    where Self.Failure == Ob.Failure {
        return zip(other).map(transform)
    }
}
