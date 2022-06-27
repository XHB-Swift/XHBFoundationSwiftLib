//
//  TweenValue.swift
//  CodeRecord-Swift
//
//  Created by 谢鸿标 on 2022/5/15.
//  Copyright © 2022 谢鸿标. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public protocol TweenValue {
    
    var values: [Double] { set get }
}

public struct TweenColor {
    
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double
}

extension TweenColor: TweenValue {
    
    public var values: [Double] {
        
        set {
            if newValue.count < 4 { return }
            red = newValue[0]
            green = newValue[1]
            blue = newValue[2]
            alpha = min(1, max(newValue[3], 0))
        }
        get {
            return [red, green, blue, alpha]
        }
    }
}

#if os(iOS)

extension TweenColor {
    
    public init(uiColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }
    
    public func makeUIColor() -> UIColor {
        return UIColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}

#else

extension TweenColor {
    
    public init(nsColor: NSColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }
    
    public func makeNSColor() -> NSColor {
        return NSColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}

#endif

extension CGFloat : TweenValue {
    
    public var values: [Double] {
        set {
            guard let v = newValue.first else { return }
            self = v
        }
        get {
            return [self]
        }
    }
}

extension CGPoint : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 1 { return }
            x = newValue[0]
            y = newValue[1]
        }
        get {
            return [x, y]
        }
    }
}

extension CGSize : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 1 { return }
            width = newValue[0]
            height = newValue[1]
        }
        get {
            return [width, height]
        }
    }
}

extension CGRect : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 3 { return }
            origin.x = newValue[0]
            origin.y = newValue[1]
            size.width = newValue[2]
            size.height = newValue[3]
        }
        get {
            return [origin.values, size.values].flatMap { return $0 }
        }
    }
}

extension CGVector : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 1 { return }
            dx = newValue[0]
            dy = newValue[1]
        }
        get {
            return [dx, dy]
        }
    }
}

extension CATransform3D : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 15 { return }
            m11 = newValue[0]; m12 = newValue[1]; m13 = newValue[2]; m14 = newValue[3]
            m21 = newValue[4]; m22 = newValue[5]; m23 = newValue[6]; m24 = newValue[7]
            m31 = newValue[8]; m32 = newValue[9]; m33 = newValue[10]; m34 = newValue[11]
            m41 = newValue[12]; m42 = newValue[13]; m43 = newValue[14]; m44 = newValue[15]
        }
        get {
            return [
                m11, m12, m13, m14,
                m21, m22, m23, m24,
                m31, m32, m33, m34,
                m41, m42, m43, m44
            ]
        }
    }
}

#if os(iOS)

extension UIOffset : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 1 { return }
            horizontal = newValue[0]
            vertical = newValue[1]
        }
        get {
            return [horizontal, vertical]
        }
    }
}

extension CGAffineTransform : TweenValue {
    
    public var values: [Double] {
        set {
            if newValue.count <= 5 { return }
            a = newValue[0]; b = newValue[1]; c = newValue[2]; d = newValue[3]
            tx = newValue[4]; ty = newValue[5]
        }
        get {
            return [
                a, b, c, d,
                tx, ty
            ]
        }
    }
}

#endif
