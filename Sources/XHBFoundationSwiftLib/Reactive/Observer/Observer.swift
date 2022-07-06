//
//  Observer.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

public protocol Observer {
    
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(_ signal: Observers.Signal<Input, Failure>)
}
