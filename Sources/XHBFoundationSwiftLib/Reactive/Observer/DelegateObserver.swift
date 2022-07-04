//
//  DelegateObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

//open class DelegateObserver<Base: AnyObject, Delegate>: Observer {
//    
//    public typealias Base = Base
//    
//    public weak var base: Base?
//    public var identifier: UUID
//    
//    public init(_ base: Base?) {
//        self.base = base
//        self.identifier = .init()
//    }
//    
//    public func notify<Value>(oldValue: Value, newValue: Value) {
//        
//    }
//}
//
//open class ObjCDelegateObserver<Base: NSObject, Delegate: NSObjectProtocol>: NSObject, Observer {
//    
//    public typealias Base = Base
//    
//    public weak var base: Base?
//    public var identifier: UUID
//    
//    public init(_ base: Base?) {
//        self.base = base
//        self.identifier = .init()
//    }
//    
//    public func notify<Value>(oldValue: Value, newValue: Value) {
//        
//    }
//}
