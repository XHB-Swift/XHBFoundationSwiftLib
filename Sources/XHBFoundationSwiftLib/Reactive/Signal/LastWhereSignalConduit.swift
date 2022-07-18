//
//  LastWhereSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class LastWhereSignalConduit<Value, Failure: Error>: AutoCommonSignalConduit<Value, Failure> {
    
    private var buffer: DataStruct.Queue<Value> = .init()
    
    let predicate: (Value) -> Bool
    
    init<Source: Observable>(source: Source, predicate: @escaping (Value) -> Bool) where Source.Output == Value, Source.Failure == Failure {
        self.predicate = predicate
        super.init(source: source)
    }
    
    override func receiveValue(_ value: Value, _ id: UUID) {
        buffer.enqueue(value)
    }
    
    override func receiveCompletion(_ id: UUID) {
        while let element = buffer.dequeue(), predicate(element) {
            super.receiveValue(element, id)
        }
        super.receiveCompletion(id)
    }
}
