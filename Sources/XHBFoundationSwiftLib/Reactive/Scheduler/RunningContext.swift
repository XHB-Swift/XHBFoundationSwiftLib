//
//  RunningContext.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

public protocol RunningContext {
    
    associatedtype Options
    associatedtype Time: Strideable where Time.Stride: TimeStride
    
    var current: Time { get }
    
    func run(action: @escaping () -> Void)
    func run(options: Options?, _ action: @escaping () -> Void)
    func run(after time: Time, options: Options?, _ action: @escaping () -> Void)
    func run(after time: Time, interval: Time.Stride, options: Options?, _ action: @escaping () -> Void)
}

public protocol TimeStride {
    
    static func seconds(_ s: Int) -> Self
    static func seconds(_ s: Double) -> Self
    static func milliseconds(_ ms: Int) -> Self
    static func microseconds(_ us: Int) -> Self
    static func nanoseconds(_ ns: Int) -> Self
}
