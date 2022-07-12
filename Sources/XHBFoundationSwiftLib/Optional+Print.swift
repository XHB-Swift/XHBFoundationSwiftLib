//
//  Optional+Print.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension Optional {
    
    public var printedString: String {
        switch self {
        case .none:
            return "nil"
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
    
}
