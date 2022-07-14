//
//  RunningContext.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

public protocol RunningContext {
    
    associatedtype Options
    associatedtype Time
    associatedtype TimeStride
    
    func run(action: @escaping () -> Void)
    func run(options: Options?, _ action: @escaping () -> Void)
    func run(after time: Time, options: Options?, _ action: @escaping () -> Void)
    func run(after time: Time, interval: TimeStride, options: Options?, _ action: @escaping () -> Void)
}
