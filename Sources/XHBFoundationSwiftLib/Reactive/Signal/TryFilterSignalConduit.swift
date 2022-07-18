//
//  TryFilterSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryFilterSignalConduit<T, E: Error>: AutoCommonSignalConduit<T, E> {
    
    let isIncluded: (T) throws -> Bool
    private var newObservers: Dictionary<UUID, AnyObserver<T,Error>>
    
    init<Source: Observable>(source: Source,_ isIncluded: @escaping (T) throws -> Bool)
    where Source.Output == T, Source.Failure == E {
        self.isIncluded = isIncluded
        self.newObservers = .init()
        super.init(source: source)
    }
    
    override func receiveSignal(_ signal: Signal, _ id: UUID) {
        newObservers[id]?.receive(self)
    }
    
    override func receiveValue(_ value: T, _ id: UUID) {
        do {
            if try !isIncluded(value) { return }
            newObservers[id]?.receive(value)
        } catch {
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
    
    override func attach<O>(observer: O) where T == O.Input, E == O.Failure, O : Observer {
        fatalError("Should use `attach<O>(observer: O) where T == O.Input, Error == O.Failure, O : Observer`")
    }
    
    func attach<O>(observer: O) where T == O.Input, Error == O.Failure, O : Observer {
        let id = observer.identifier
        newObservers[id] = .init(observer)
        anySource?.subscribe(makeBridger(id))
    }
}
