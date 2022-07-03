//
//  DelegateObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

open class DelegateObserver<Base: AnyObject, Delegate>: AnyObserver {
    
    public init(_ base: Base) {
        super.init(base, nil)
    }
}

open class ObjCDelegateObserver<Base: NSObject, Delegate: NSObjectProtocol>: DelegateObserver<Base, Delegate> {
    
    public var objcDelegateObject: ObjCDelegate?
    
    public init(_ base: Base, _ delegateObject: ObjCDelegate) {
        super.init(base)
        objcDelegateObject = delegateObject
    }
}

extension ObjCDelegateObserver {
    
    open class ObjCDelegate: NSObject {
        
    }
}
