//
//  TryTransformSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/13.
//

import Foundation

final class TryTransformSignalConduit<T, V, E: Error>: ControlSignalConduit<T, Error, V, E> {
    
    let tryTransform: (V) throws -> T
    
    init(tryTransform: @escaping (V) throws -> T) {
        self.tryTransform = tryTransform
    }
    
    override func receive(value: V) {
        do {
            anyObserver?.receive(try tryTransform(value))
        } catch {
            anyObserver?.receive(.failure(error))
        }
    }
}
