//
//  Observation.swift
//  
//
//  Created by 谢鸿标 on 2022/7/5.
//

import Foundation

public protocol Observation: AnyObject, Observable {
    
    func send(_ signal: Signal)
    
    func send(_ value: Self.Output)
    
    func send(_ failure: Self.Failure)
}

extension Observation where Self.Output == Void {
    
    func send() {}
}
