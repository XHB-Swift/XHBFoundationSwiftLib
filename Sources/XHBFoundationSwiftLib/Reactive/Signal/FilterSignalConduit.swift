//
//  FilterSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class FilterSignalConduit<T, E: Error>: ControlSignalConduit<T, E, T, E> {
    
    let isIncluded: (T) -> Bool
    
    init(_ isIncluded: @escaping (T) -> Bool) {
        self.isIncluded = isIncluded
    }
    
    override func receive(value: T) {
        if !isIncluded(value) { return }
        anyObserver?.receive(value)
    }
}
