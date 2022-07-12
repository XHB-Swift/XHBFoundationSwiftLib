//
//  Observables+Merge.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation


extension Observables {
    
    public struct Merge<Source, Others>: Observable
    where Source: Observable, Others: Swift.Collection, Others.Element: Observable,
            Source.Output == Others.Element.Output, Source.Failure == Others.Element.Failure {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let others: Others
        private let _valueBuffer: _MergeValueBuffer<Output>
        
        public init(_ source: Source, _ others: Others) {
            self.source = source
            self.others = others
            self._valueBuffer = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            self._valueBuffer.attach(observer)
            self.source.subscribe(self._valueBuffer.nObserver)
            self.others.forEach {
                $0.subscribe(self._valueBuffer.nObserver)
            }
        }
    }
}

extension Observables.Merge {
    
    fileprivate final class _MergeValueBuffer<Element>: SignalConduit {
        
        private var storage: DataStruct.Queue<Element>
        private var observer: AnyObserver<Element, Failure>?
        
        var nObserver: ClosureObserver<Element, Failure> {
            return .init({[weak self] in self?.appendN($0) },
                         {[weak self] in self?.emit($0) })
        }
        
        override init() {
            storage = .init()
        }
        
        private func appendN(_ value: Element) {
            lock.lock()
            defer { lock.unlock() }
            storage.enqueue(value)
            send()
        }
        
        private func emit(_ failure: Failure) {
            lock.lock()
            defer { lock.unlock() }
            observer?.receive(.failure(failure))
        }
        
        override func send() {
            guard requirement > .none,
            let first = storage.dequeue() else { return }
            observer?.receive(first)
        }
        
        override func dispose() {
            if storage.isEmpty { return }
            storage.clear()
            observer = nil
        }
        
        public func attach<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Element == Ob.Input {
            self.observer = .init(observer)
            self.observer?.receive(self)
        }
    }
    
}

extension Observable {
    
    public func merge<Others>(with others: Others) -> Observables.Merge<Self, Others>
    where Others: Swift.Collection, Others.Element: Observable, Self.Failure == Others.Element.Failure, Self.Output == Others.Element.Output {
        return .init(self, others)
    }
    
    public func merge<Ob: Observable>(with other: Ob) -> Observables.Merge<Self, Array<Ob>>
    where Self.Failure == Ob.Failure, Self.Output == Ob.Output {
        return merge(with: [other])
    }
}
