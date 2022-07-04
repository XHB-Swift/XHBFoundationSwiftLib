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
    
    func receive(_ input: Input)
    func receive(_ failure: Failure)
}