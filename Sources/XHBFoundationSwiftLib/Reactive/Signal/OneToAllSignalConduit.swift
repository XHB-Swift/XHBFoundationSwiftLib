//
//  OneToAllSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

class OneToAllSignalConduit<Source: Observable>: SignalConduit {
    
    let receiveValue: (Source.Output, UUID) -> Void
    let receiveFailure: (Source.Failure, UUID) -> Void
    let receiveCompletion: (UUID) -> Void
    
    private var anyObservable: AnyObservable<Source.Output, Source.Failure>?
    
    init(_ receiveValue: @escaping (Source.Output, UUID) -> Void,
         _ receiveFailure: @escaping (Source.Failure, UUID) -> Void,
         _ receiveCompletion: @escaping (UUID) -> Void) {
        
        self.receiveValue = receiveValue
        self.receiveFailure = receiveFailure
        self.receiveCompletion = receiveCompletion
    }
    
    private func _receiveValue(_ value: Source.Output) {
        lock.lock()
        defer { lock.unlock() }
        if anyObservable == nil { return }
        receiveValue(value, identifier)
    }
    
    private func _receiveFailure(_ failure: Source.Failure) {
        lock.lock()
        defer { lock.unlock() }
        receiveFailure(failure, identifier)
    }
    
    private func _receiveCompletion() {
        lock.lock()
        defer { lock.unlock() }
        receiveCompletion(identifier)
    }
    
    override func dispose() {
        anyObservable = nil
    }
    
    func attach<Ob: Observable>(to observable: Ob) where Source.Failure == Ob.Failure, Source.Output == Ob.Output {
        if anyObservable == nil {
            anyObservable = .init(observable)
        }
        let bridger: ClosureObserver<Source.Output, Source.Failure> =
            .init({[weak self] in self?._receiveValue($0)},
                  {[weak self] in self?._receiveFailure($0)},
                  {[weak self] in self?._receiveCompletion()})
        anyObservable?.subscribe(bridger)
        bridger.receive(self)
    }
}
