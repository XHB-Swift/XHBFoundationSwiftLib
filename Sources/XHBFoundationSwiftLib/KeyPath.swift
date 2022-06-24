//
//  KeyPath.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation

public protocol KeyPathEditable {
    
    func set<T>(value: T, for property: PartialKeyPath<Self>) throws -> Self
}

extension KeyPathEditable {
    
    func set<T>(value: T, for property: PartialKeyPath<Self>) throws -> Self {
        guard let writableProperty = property as? WritableKeyPath<Self,T> else {
            throw CommonError(code: -101, reason: "属性设置失败")
        }
        var newSelf = self
        newSelf[keyPath: writableProperty] = value
        return newSelf
    }
}
