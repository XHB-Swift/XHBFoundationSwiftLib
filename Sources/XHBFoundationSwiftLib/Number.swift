//
//  Number.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation

extension FloatingPoint {
    
    public static var pi_2: Self { return Self.pi / 2 }
    public static var pi_3: Self { return Self.pi / 3 }
    public static var pi_4: Self { return Self.pi / 4 }
    public static var pi_6: Self { return Self.pi / 6 }
    public static var m_2_pi: Self { return Self.pi * 2 }
    
    public var degree: Self {
        return self * Self(180) / Self.pi
    }
    
    public var radian: Self {
        return self * Self.pi / Self(180)
    }
}
