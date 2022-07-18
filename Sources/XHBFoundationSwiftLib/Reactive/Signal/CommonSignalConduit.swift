//
//  CommonSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

class CommonSignalConduit<Value, Failure: Error>: SignalConduit {
    
    private(set) var anySource: AnyObservable<Value, Failure>?
    private var allObservers: Dictionary<UUID, AnyObserver<Value, Failure>>
    private var signal: Signal?
    
    init<S: Observable>(source: S? = nil) where S.Output == Value, S.Failure == Failure {
        if let s = source {
            anySource = .init(s)
        }
        allObservers = .init()
    }
    
    func observer(with id: UUID) -> AnyObserver<Value, Failure>? {
        return allObservers[id]
    }
    
    func makeBridger(_ id: UUID) -> ClosureObserver<Value, Failure> {
        var bridger: ClosureObserver<Value, Failure> =
            .init({[weak self] in self?._receiveValue($0, id)},
                  {[weak self] in self?._receiveFailure($0, id)},
                  {[weak self] in self?._receiveCompletion(id)})
        bridger._signal = {[weak self] in self?._receiveSignal($0, id) }
        return bridger
    }
    
    func receiveSignal(_ signal: Signal, _ id: UUID) {
        self.signal = signal
        guard let _ = self.signal else { return }
        allObservers[id]?.receive(self)
    }
    
    func receiveValue(_ value: Value, _ id: UUID) {
        allObservers[id]?.receive(value)
    }
    
    func receiveFailure(_ failure: Failure, _ id: UUID) {
        let observer = allObservers.removeValue(forKey: id)
        observer?.receive(.failure(failure))
    }
    
    func receiveCompletion(_ id: UUID) {
        let observer = allObservers.removeValue(forKey: id)
        observer?.receive(.finished)
    }
    
    func forEachObserver(action: @escaping (UUID, AnyObserver<Value, Failure>) -> Void) {
        allObservers.forEach(action)
    }
    
    override func dispose() {
        signal?.cancel()
        signal = nil
        allObservers.removeAll()
        anySource = nil
    }
    
    private func _receiveSignal(_ signal: Signal, _ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        receiveSignal(signal, id)
    }
    
    private func _receiveValue(_ value: Value, _ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        receiveValue(value, id)
    }
    
    private func _receiveFailure(_ failure: Failure, _ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        receiveFailure(failure, id)
    }
    
    private func _receiveCompletion(_ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        receiveCompletion(id)
    }
    
    func add<O: Observer>(observer: O) where O.Input == Value, O.Failure == Failure {
        let id = observer.identifier
        allObservers[id] = .init(observer)
    }
    
    func attach<O: Observer>(observer: O) where O.Input == Value, O.Failure == Failure {
        add(observer: observer)
        anySource?.subscribe(makeBridger(observer.identifier))
    }
}
