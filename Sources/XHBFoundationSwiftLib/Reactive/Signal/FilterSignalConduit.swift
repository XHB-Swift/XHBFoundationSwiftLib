//
//  FilterSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class FilterSignalConduit<T, E: Error>: AutoCommonSignalConduit<T, E> {
    
    let isIncluded: (T) -> Bool
    
    init<Source: Observable>(source: Source, _ isIncluded: @escaping (T) -> Bool) where Source.Output == T, Source.Failure == E {
        self.isIncluded = isIncluded
        super.init(source: source)
    }
    
    override func receiveValue(_ value: T, _ id: UUID) {
        if !isIncluded(value) { return }
        super.receiveValue(value, id)
    }
}
