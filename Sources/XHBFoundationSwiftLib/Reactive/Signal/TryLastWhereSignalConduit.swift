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
        buffer.forEach { [weak self] in
            guard let strongSelf = self else { return }
            do {
                guard try strongSelf.predicate($0) else { return }
                strongSelf.anyObserver?.receive($0)
            } catch {
                strongSelf.anyObserver?.receive(.failure(error))
            }
        }
        anyObserver?.receive(.finished)
    }
}
