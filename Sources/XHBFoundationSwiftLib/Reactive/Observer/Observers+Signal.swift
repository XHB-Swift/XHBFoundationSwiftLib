//
//  Observers+Signal.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observers {
    
    @frozen public enum Signal<Value, Failure: Error> {
        
        case receiving(Value)
        case finished
        case failure(Failure)
    }
}
