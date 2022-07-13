//
//  TryFilterSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryFilterSignalConduit<T, E: Error>: ControlSignalConduit<T, Error, T, E> {
    
    let isIncluded: (T) throws -> Bool
    
    init(_ isIncluded: @escaping (T) throws -> Bool) {
        self.isIncluded = isIncluded
    }
    
    override func receive(value: T) {
        do {
            if try !isIncluded(value) { return }
            anyObserver?.receive(value)
        } catch {
            disposeObservable()
            anyObserver?.receive(.failure(error))
        }
    }
}
