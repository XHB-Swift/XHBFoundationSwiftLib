//
//  TryTransformSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryTransformSignalConduit<T, V, E: Error>: AutoCommonSignalConduit<V, E> {
    
    let tryTransform: (V) throws -> T
    private var newObservers: Dictionary<UUID, AnyObserver<T,Error>>
    
    init<Source: Observable>(source: Source, tryTransform: @escaping (V) throws -> T)
    where Source.Output == V, Source.Failure == E {
        self.tryTransform = tryTransform
        self.newObservers = .init()
        super.init(source: source)
    }
    
    override func receiveSignal(_ signal: Signal, _ id: UUID) {
        newObservers[id]?.receive(signal)
    }
    
    override func receiveValue(_ value: V, _ id: UUID) {
        do {
            newObservers[id]?.receive(try tryTransform(value))
        } catch {
            cancel()
            newObservers[id]?.receive(.failure(error))
        }
    }
    
    override func receiveFailure(_ failure: E, _ id: UUID) {
        cancel()
        newObservers[id]?.receive(.failure(failure))
    }
    
    override func receiveCompletion(_ id: UUID) {
        cancel()
        newObservers[id]?.receive(.finished)
    }
    
    override func dispose() {
        super.dispose()
        newObservers.removeAll()
    }
    
    override func attach<O>(observer: O) where V == O.Input, E == O.Failure, O : Observer {
        fatalError("Should use `attach<O>(observer: O) where T == O.Input, Error == O.Failure, O : Observer`")
    }
    
    func attach<O>(observer: O) where T == O.Input, Error == O.Failure, O : Observer {
        let id = observer.identifier
        newObservers[id] = .init(observer)
        anySource?.subscribe(makeBridger(id))
    }
}
