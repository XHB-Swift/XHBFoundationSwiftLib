//
//  Observables+MeasureInterval.swift
//  
//
//  Created by xiehongbiao on 2022/7/18.
//

import Foundation


extension Observables {
    
    public struct MeasureInterval<Source: Observable, Context: RunningContext>: Observable {
        
        public typealias Output = Context.Time.Stride
        public typealias Failure = Source.Failure
        
        public let source: Source
        public let context: Context
        fileprivate let _signalConduit: _MeasureIntervalSignalConduit
        
        public init(source: Source, context: Context) {
            self.source = source
            self.context = context
            self._signalConduit = .init(source: source, context: context)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.MeasureInterval {
    
    fileprivate final class _MeasureIntervalSignalConduit: SignalConduit {
        
        private final class _ObserverSubscribed {
            
            var observer: AnyObserver<Output, Failure>
            var bridger: ClosureObserver<Source.Output, Failure>
            var id: UUID
            var time: Context.Time
            
            init<O: Observer>(observer: O, bridger: ClosureObserver<Source.Output, Failure>, id: UUID, time: Context.Time)
            where O.Input == Output, O.Failure == Failure {
                self.observer = .init(observer)
                self.bridger = bridger
                self.id = id
                self.time = time
            }
        }
        
        private var allObservers: Dictionary<UUID, _ObserverSubscribed>
        private let source: Source
        private let context: Context
        fileprivate var options: Context.Options?
        private var signalSource: Signal?
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
        
        init(source: Source, context: Context) {
            self.source = source
            self.context = context
            self.allObservers = .init()
        }
        
        private func _receiveValue(_ value: Source.Output, _ id: UUID) {
            context.run(options: options) {
                self._receiveValueInOptions(value, id)
            }
        }
        
        private func _receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            context.run(options: options) {
                self._receiveFailureInOptions(failure, id)
            }
        }
        
        private func _receiveCompletion(_ id: UUID) {
            context.run(options: options) {
                self._receiveCompletionInOptions(id)
            }
        }
        
        private func _receiveValueInOptions(_ value: Source.Output, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            guard let record = allObservers[id] else { return }
            let distance = context.current.distance(to: record.time)
            record.observer.receive(distance)
            record.time = context.current
            allObservers[id] = record
        }
        
        private func _receiveFailureInOptions(_ failure: Source.Failure, _ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            allObservers[id]?.observer.receive(.failure(failure))
        }
        
        private func _receiveCompletionInOptions(_ id: UUID) {
            lock.lock()
            defer { lock.unlock() }
            allObservers[id]?.observer.receive(.finished)
        }
        
        private func _receiveSignal(_ signal: Signal, _ id: UUID) {
            signalSource = signal
            allObservers[id]?.observer.receive(self)
        }
        
        override func dispose() {
            signalSource?.cancel()
            signalSource = nil
            allObservers.removeAll()
        }
        
        func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            lock.lock()
            defer { lock.unlock() }
            let id = observer.identifier
            let time = context.current
            var bridger: ClosureObserver<Source.Output, Failure> =
                .init({ [weak self] in self?._receiveValue($0, id)},
                      { [weak self] in self?._receiveFailure($0, id)},
                      { [weak self] in self?._receiveCompletion(id)})
            bridger._signal = { [weak self] in self?._receiveSignal($0, id) }
            allObservers[id] = .init(observer: observer,
                                     bridger: bridger,
                                     id: id,
                                     time: time)
            source.subscribe(bridger)
        }
    }
}

extension Observable {
    
    public func measureInterval<R: RunningContext>(using context: R, options: R.Options? = nil) -> Observables.MeasureInterval<Self, R> {
        let m: Observables.MeasureInterval<Self, R> = .init(source: self, context: context)
        m._signalConduit.options = options
        return m
    }
    
}
