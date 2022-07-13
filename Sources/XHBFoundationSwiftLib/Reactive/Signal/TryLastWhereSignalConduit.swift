//
//  TryLastWhereSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryLastWhereSignalConduit<Value, Failure: Error>: ControlSignalConduit<Value, Error, Value, Failure> {
    
    private var buffer: DataStruct.Queue<Value> = .init()
    
    let predicate: (Value) throws -> Bool
    
    init(predicate: @escaping (Value) throws -> Bool) {
        self.predicate = predicate
    }
    
    override func receive(value: Value) {
        buffer.enqueue(value)
    }
    
    override func receiveCompletion() {
        
        for element in buffer {
            do {
                guard try predicate(element) else { continue }
                anyObserver?.receive(element)
            } catch {
                disposeObservable()
                anyObserver?.receive(.failure(error))
                return
            }
        }
        disposeObservable()
        anyObserver?.receive(.finished)
    }
}
