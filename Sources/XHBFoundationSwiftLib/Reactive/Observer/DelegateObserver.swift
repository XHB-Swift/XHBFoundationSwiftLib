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
