//
//  PassSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

class PassSignalConduit<Value, Failure: Error>: OneToOneSignalConduit<Value, Failure, Value, Failure> {
    
    override func receive(value: Value) {
        anyObserver?.receive(value)
    }
    
    override func receive(failure: Failure) {
        anyObserver?.receive(.failure(failure))
    }
    
    override func receiveCompletion() {
        anyObserver?.receive(.finished)
    }
    
}
