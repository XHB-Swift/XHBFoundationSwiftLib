//
//  NSObject+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/3.
//

import Foundation

public protocol RespondingExtension {
    
    associatedtype Base
    
    var responding: Responding<Base> { get set }
}

extension RespondingExtension {
    
    public var responding: Responding<Self> {
        get { .init(self) }
        set {}
    }
}

extension NSObject: RespondingExtension {}
