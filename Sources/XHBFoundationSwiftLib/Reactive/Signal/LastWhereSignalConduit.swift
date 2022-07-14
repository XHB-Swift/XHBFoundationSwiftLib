//
//  LastWhereSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class LastWhereSignalConduit<Value, Failure: Error>: OneToOneSignalConduit<Value, Failure, Value, Failure> {
    
    private var buffer: DataStruct.Queue<Value> = .init()
    
    let predicate: (Value) -> Bool
    
    init(predicate: @escaping (Value) -> Bool) {
        self.predicate = predicate
    }
    
    override func receive(value: Value) {
        buffer.enqueue(value)
    }
    
    override func receiveCompletion() {
        buffer.forEach { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.predicate($0) else { return }
            strongSelf.anyObserver?.receive($0)
        }
        anyObserver?.receive(.finished)
    }
}
