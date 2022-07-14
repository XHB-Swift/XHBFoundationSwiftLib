//
//  TransformSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TransformSignalConduit<T, V, E: Error>: OneToOneSignalConduit<T, E, V, E> {
    
    let transform: (V) -> T
    
    init(transform: @escaping (V) -> T) {
        self.transform = transform
    }
    
    override func receive(value: V) {
        anyObserver?.receive(transform(value))
    }
}
