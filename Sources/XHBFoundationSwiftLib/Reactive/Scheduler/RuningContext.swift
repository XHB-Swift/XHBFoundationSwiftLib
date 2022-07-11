//
//  RuningContext.swift
//  
//
//  Created by xiehongbiao on 2022/7/8.
//

import Foundation

public protocol RuningContext {
    
    func run<Options>(options: Options?, _ action: @escaping () -> Void)
    func run<Options, Time>(after time: Time, options: Options?, _ action: @escaping () -> Void)
    func run<Options, Time, TimeStride>(after time: Time, interval: TimeStride, options: Options?, _ action: @escaping () -> Void)
    
}
