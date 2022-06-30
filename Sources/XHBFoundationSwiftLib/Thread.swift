//
//  Thread.swift
//  
//
//  Created by xiehongbiao on 2022/6/30.
//

import Foundation

public func synchronized<Object, Value>(_ locked: Object,
                                        _ action: () -> Value) -> Value {
    objc_sync_enter(locked)
    let result = action()
    objc_sync_exit(locked)
    return result
}
