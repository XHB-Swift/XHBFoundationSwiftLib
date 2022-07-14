//
//  File.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension JSONDecoder: DataDecoder {
    
    public typealias Input = Data
}

extension JSONEncoder: DataEncoder {
    
    public typealias Output = Data
}
