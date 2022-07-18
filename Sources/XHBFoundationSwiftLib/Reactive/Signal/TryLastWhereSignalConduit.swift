//
//  TryLastWhereSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryLastWhereSignalConduit<T, E: Error>: AutoCommonSignalConduit<T, E> {
    
    private var buffer: DataStruct.Queue<T> = .init()
    private var newObservers: Dictionary<UUID, AnyObserver<T,Error>>
    
    let predicate: (T) throws -> Bool
    
    init<Source: Observable>(source: Source, predicate: @escaping (T) throws -> Bool)
    where Source.Output == T, Source.Failure == E  {
        self.predicate = predicate
        self.newObservers = .init()
        super.init(source: source)
    }
    
    override func receiveSignal(_ signal: Signal, _ id: UUID) {
        newObservers[id]?.receive(self)
    }
    
    override func receiveValue(_ value: T, _ id: UUID) {
        buffer.enqueue(value)
    }
    
    override func receiveFailure(_ failure: E, _ id: UUID) {
        cancel()
        newObservers[id]?.receive(.failure(failure))
    }
    
    override func receiveCompletion(_ id: UUID) {
        while let element = buffer.dequeue() {
            do {
                guard try predicate(element) else { continue }
                newObservers[id]?.receive(element)
            } catch {
                cancel()
                newObservers[id]?.receive(.failure(error))
                return
            }
        }
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
