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
    
    init<S: Observable>(source: S) where S.Output == Value, S.Failure == Failure {
        anySource = .init(source)
        allObservers = .init()
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
    
    override func send() {
        forEachObserver { [weak self] (_, observer) in
            guard let strongSelf = self else { return }
            observer.receive(strongSelf)
        }
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
    
    override func dispose() {
        allObservers.removeAll()
        anySource = nil
    }
    
    func attach<O: Observer>(observer: O) where O.Input == Value, O.Failure == Failure {
        let id = observer.identifier
        allObservers[id] = .init(observer)
        let bridger: ClosureObserver<Value, Failure> =
            .init({[weak self] in self?._receiveValue($0, id)},
                  {[weak self] in self?._receiveFailure($0, id)},
                  {[weak self] in self?._receiveCompletion(id)})
        anySource?.subscribe(bridger)
    }
}
