//
//  AutoCommonSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

class AutoCommonSignalConduit<Value, Failure: Error>: CommonSignalConduit<Value, Failure> {
    
    override func attach<O>(observer: O) where Value == O.Input, Failure == O.Failure, O : Observer {
        super.attach(observer: observer)
        observer.receive(self)
    }
    
}
