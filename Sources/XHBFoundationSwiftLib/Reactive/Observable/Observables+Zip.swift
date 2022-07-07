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
            self._valueBuffer.middleObserver = .init(observer)
            self.a.subscribe(self._valueBuffer.aObserver)
            self.b.subscribe(self._valueBuffer.bObserver)
        }
    }
    
}

extension Observables.Zip {
    
    fileprivate final class _ZipValueBuffer<A, B> {
        
        private var aValueQueue: ContiguousArray<A>
        private var emitIndex: Int = -1
        private let lock: DispatchSemaphore = .init(value: 1)
        
        var middleObserver: AnyObserver<(A ,B), Failure>?
        
        var aObserver: ClosureObserver<A, Failure> {
            return .init({ [weak self] in self?.aValueQueue.append($0) },
                         { [weak self] in self?.emit($0) })
        }
        
        var bObserver: ClosureObserver<B, Failure> {
            return .init({ [weak self] in self?.emitB($0) },
                         { [weak self] in self?.emit($0) })
        }
        
        init() { aValueQueue = .init() }
        
        private func emit(_ failure: Failure) {
            middleObserver?.receive(.failure(failure))
        }
        
        private func emitB(_ value: B) {
            lock.wait()
            defer {
                lock.signal()
            }
            if aValueQueue.isEmpty { return }
            emitIndex += 1
            let range = 0..<aValueQueue.count
            if !range.contains(emitIndex) { return }
            let a = aValueQueue[emitIndex]
            middleObserver?.receive(.receiving((a, value)))
            aValueQueue.remove(at: emitIndex)
            emitIndex -= 1
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
