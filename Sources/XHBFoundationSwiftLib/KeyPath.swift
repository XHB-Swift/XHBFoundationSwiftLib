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
    
    public func set<T>(value: T, for property: PartialKeyPath<Self>) throws -> Self {
        guard let writableProperty = property as? WritableKeyPath<Self,T> else {
            throw CommonError(code: -101, reason: "属性设置失败")
        }
        var newSelf = self
        newSelf[keyPath: writableProperty] = value
        return newSelf
    }
}

extension NSObject {
    
    open func runtimePropertyLazyBinding<T>(_ key: UnsafeRawPointer, _ lazyCreation: () -> T) -> T {
        if let value = objc_getAssociatedObject(self, key) as? T {
            return value
        }
        let value = lazyCreation()
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return value
    }
}
