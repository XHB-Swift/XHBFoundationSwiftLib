//
//  Observables+Share.swift
//  
//
//  Created by xiehongbiao on 2022/7/18.
//

import Foundation


extension Observables {
    
    final public class Share<Source: Observable>: Observable, Equatable {
        
        public typealias Output = Source.Output
        public typealias Failure = Source.Failure
        
        public let source: Source
        private let _signalConduit: _ShareSignalConduit
        
        public init(source: Source) {
            self.source = source
            self._signalConduit = .init(source: source)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer)
        }
        
        public static func == (lhs: Share<Source>, rhs: Share<Source>) -> Bool {
            return lhs === rhs
        }
    }
}

extension Observables.Share {
    
    fileprivate final class _ShareSignalConduit: SignalConduit {
        
        private var allObsevers: Dictionary<UUID, AnyObserver<Output, Failure>>
        private var bridger: ClosureObserver<Output, Failure>?
        private var _signalSource: Signal?
        let source: Source
        
        init(source: Source) {
            self.source = source
            self.allObsevers = .init()
        }
        
        private func sendSignalIfPossible(to id: UUID) {
            guard let _ = _signalSource else { return }
            allObsevers[id]?.receive(self)
        }
        
        private func _receiveSignal(_ signal: Signal, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            _signalSource = signal
            sendSignalIfPossible(to: id)
        }
        
        private func _receiveValue(_ value: Output, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            allObsevers[id]?.receive(value)
        }
        
        private func _receiveFailure(_ failure: Failure, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            allObsevers[id]?.receive(.failure(failure))
        }
        
        private func _receiveCompletion(_ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            allObsevers[id]?.receive(.finished)
        }
        
        override func dispose() {
            _signalSource?.cancel()
            _signalSource = nil
            bridger = nil
            allObsevers.removeAll()
        }
        
        func attach<Ob>(_ observer: Ob) where Ob : Observer, Source.Failure == Ob.Failure, Source.Output == Ob.Input {
            lock.lock()
            defer { lock.unlock() }
            let anyOb: AnyObserver = .init(observer)
            let id: UUID = anyOb.identifier
            allObsevers[id] = anyOb
            sendSignalIfPossible(to: id)
            if bridger == nil {
                bridger = .init({[weak self] in self?._receiveValue($0,id)},
                                {[weak self] in self?._receiveFailure($0, id)},
                                {[weak self] in self?._receiveCompletion(id)})
                bridger?._signal = { [weak self] in self?._receiveSignal($0, id) }
                source.subscribe(bridger!)
            }
        }
    }
}

extension Observable {
    
    public func share() -> Observables.Share<Self> {
        return .init(source: self)
    }
}
