//
//  CommonError.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation

public struct CommonError: Error {
    
    public var code: Int
    public var reason: String
    
    public init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }
}
