//
//  Observers+Completion.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observers {
    
    @frozen public enum Completion<Failure: Error> {
        
        case finished
        case failure(Failure)
    }
}
