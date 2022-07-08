//
//  Scheduler.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

public protocol Scheduler {
    
    func schedule<Options>(options: Options?, _ action: @escaping () -> Void)
    func schedule<Options, Time>(after time: Time, options: Options?, _ action: @escaping () -> Void)
    func schedule<Options, Time, TimeStride>(after time: Time, interval: TimeStride, options: Options?, _ action: @escaping () -> Void)
    
}
