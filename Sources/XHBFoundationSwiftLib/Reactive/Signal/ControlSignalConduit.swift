//
//  ControlSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

class ControlSignalConduit<T, F1: Error, V, F2: Error>: SignalConduit {
    
    private(set) var anyObserver: AnyObserver<T, F1>?
    private(set) var anyObservable: AnyObservable<V, F2>?
    
    private var middleObserver: ClosureObserver<V, F2> {
        return .init({ [weak self] in self?._receive($0) },
                     { [weak self] in self?._receive($0) },
                     { [weak self] in self?.receiveCompletion() })
    }
    
    private func _receive(_ value: V) {
        lock.lock()
        defer { lock.unlock() }
        receive(value: value)
    }
    
    private func _receive(_ failure: F2) {
        lock.lock()
        defer { lock.unlock() }
        receive(failure: failure)
    }
    
    private func _receiveCompletion() {
        lock.lock()
        defer { lock.unlock() }
        receiveCompletion()
    }
    
    func receive(value: V) {}
    func receive(failure: F2) {}
    func receiveCompletion() {}
    
    
    override func dispose() {
        anyObserver = nil
        anyObservable = nil
    }
    
    func attach<O: Observer, Ob: Observable>(_ observer: O, to observable: Ob)
    where V == Ob.Output, T == O.Input, F1 == O.Failure, F2 == Ob.Failure {
        self.anyObserver = .init(observer)
        self.anyObservable = .init(observable)
        self.anyObservable?.subscribe(self.middleObserver)
        self.anyObserver?.receive(self)
    }
}
