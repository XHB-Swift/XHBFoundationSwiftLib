//
//  TransformSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TransformSignalConduit<T, V, E: Error>: AutoCommonSignalConduit<V, E> {
    
    let transform: (V) -> T
    private var newObservers: Dictionary<UUID, AnyObserver<T,E>>
    
    init<Source: Observable>(source: Source, transform: @escaping (V) -> T)
    where Source.Output == V, Source.Failure == E {
        self.transform = transform
        newObservers = .init()
        super.init(source: source)
    }
    
    override func receiveSignal(_ signal: Signal, _ id: UUID) {
        newObservers[id]?.receive(self)
    }
    
    override func receiveValue(_ value: V, _ id: UUID) {
        newObservers[id]?.receive(transform(value))
    }
    
    override func receiveFailure(_ failure: E, _ id: UUID) {
        newObservers[id]?.receive(.failure(failure))
    }
    
    override func receiveCompletion(_ id: UUID) {
        newObservers[id]?.receive(.finished)
    }
    
    override func dispose() {
        super.dispose()
        newObservers.removeAll()
    }
    
    override func attach<O>(observer: O) where V == O.Input, E == O.Failure, O : Observer {
        fatalError("Should call `attach<O>(observer: O) where T == O.Input, E == O.Failure, O : Observer`")
    }
    
    func attach<O>(observer: O) where T == O.Input, E == O.Failure, O : Observer {
        let id = observer.identifier
        newObservers[id] = .init(observer)
        anySource?.subscribe(makeBridger(id))
    }
}
