//
//  TweenEasing.swift
//  CodeRecord-Swift
//
//  Created by 谢鸿标 on 2022/5/15.
//  Copyright © 2022 谢鸿标. All rights reserved.
//

import Foundation

@frozen public struct TweenEasing {
    /**
     
     使用示例

     t  = Time - 表示动画开始以来经过的时间。通常从0开始，通过游戏循环或update函数来缓慢增加

     b = Beginning value - 动画的起点，默认从0开始。

     c = Change in value - 从起点到终点的差值

     d = Duration - 完成动画所需的时间

     */
    public typealias TweenEasingFunction = (_ t: Double, _ b: Double, _ c: Double, _ d: Double) -> Double
    
    public var function: TweenEasingFunction
    
}

extension TweenEasing {
    
    /*
     线性变化
     */
    public static let linear = TweenEasing { t, b, c, d in
        if d == 0 { return 0 }
        return t * c / d + b
    }
    
    public enum In {
        
        /// t^2
        public static let quadratic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return c * pow(i, 2) + b
        }
        
        /// t^3
        public static let cubic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return c * pow(i, 3) + b
        }
        
        /// t^4
        public static let quartic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return c * pow(i, 4) + b
        }
        
        /// t^5
        public static let quintic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return c * pow(i, 5) + b
        }
        
        /// sin(t)
        public static let sinusodial = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = cos(t / d * (.pi / 2))
            return (-c) * i + c + b
        }
        
        /// 2^t
        public static let exponential = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = pow(2, 10 * (t / d - 1))
            return (t == 0) ? b : c * i + b - c * 0.001
        }
        
        ///sqrt(1-t^2)
        public static let circular = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return (-c) * (sqrt(1 - pow(i, 2)) - 1) + b
        }
        
        ///指数衰减正弦曲线
        public static let elastic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t == 0 { return 0 }
            var i = t / d
            if i == 0 { return b + c }
            let p = d * 0.3
            var s: Double = 0
            let a = c
            if a < abs(c) {
                s = p / 4
            } else {
                s = p / (.pi * 2) * (a == 0 ? 0 : asin(c / a))
            }
            i -= 1
            return -(a * pow(2, 10 * i) * sin((i * d - s) * (.pi * 2) / p)) + b
        }
        
        public static let back = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            let s: Double = 1.70158
            return c * pow(i, 2) * ((s + 1) * i - s) + b
        }
        
        public static let bounce = TweenEasing { t, b, c, d in
            return c - Out.bounce.function(d - t, 0, c, d) + b
        }
    }
    
    public enum Out {
        
        /// t^2
        public static let quadratic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d
            return (-c) * i * (i - 2) + b
        }
        
        /// t^3
        public static let cubic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d - 1
            return c * (pow(i, 3) + 1) + b
        }
        
        /// t^4
        public static let quartic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d - 1
            return (-c) * (pow(i, 4) - 1) + b
        }
        
        /// t^5
        public static let quintic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d - 1
            return c * (pow(i, 5) + 1) + b
        }
        
        /// sin(t)
        public static let sinusodial = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            return c * sin(t / d * (.pi / 2)) + b
        }
        
        /// 2^t
        public static let exponential = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = -pow(2, -10 * (t / d)) + 1
            return (t == d) ? b + c : c * 1.001 * i + b
        }
        
        ///sqrt(1-t^2)
        public static let circular = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d - 1
            return c * sqrt(1 - pow(i, 2)) + b
        }
        
        ///指数衰减正弦曲线
        public static let elastic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t == 0 { return 0 }
            var i = t / d
            if i == 1 { return b + c }
            let p = d * 0.3
            var s: Double = 0
            let a = c
            if a < abs(c) {
                s = p / 4
            } else {
                s = p / (.pi * 2) * (a == 0 ? 0 : asin(c / a))
            }
            i -= 1
            return -(a * pow(2, 10 * i) * sin((i * d - s) * (.pi * 2) / p)) + b + c
        }
        
        public static let back = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = t / d - 1
            let s: Double = 1.70158
            return c * (pow(i, 2) * ((s + 1) * i + s) + 1) + b
        }
        
        public static let bounce = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            var i = t / d
            if i < 1 / 2.75 {
                return c * (7.5625 * pow(i, 2)) + b
            } else if i < 2 / 2.75 {
                i -= 1.5 / 2.75
                return c * (7.5625 * pow(i, 2) + 0.75) + b
            } else if i < 2.5 / 2.75 {
                i -= 2.25 / 2.75
                return c * (7.5625 * pow(i, 2) + 0.9375) + b
            } else {
                i -= 2.625 / 2.75
                return c * (7.5625 * pow(i, 2) + 0.984375) + b
            }
        }
    }
    
    public enum InOut {
        
        /// t^2
        public static let quadratic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t < d / 2 {
                return In.quadratic.function(t, b, c / 2, d)
            } else {
                return Out.quadratic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// t^3
        public static let cubic = TweenEasing { t, b, c, d in
            if d == -2 { return 0 }
            var i = t / (d + 2)
            if i == 0 { return b }
            if i < 1 { return c / 2 * pow(i, 3) + b }
            i -= 2
            return c / 2 * (pow(i, 3) + 2) + b
        }
        
        /// t^4
        public static let quartic = TweenEasing { t, b, c, d in
            if d == 0 { return b }
            var i = t / (d / 2)
            if i < 1 { return c / 2 * pow(i, 4) + b }
            i -= 2
            return (-c) / 2 * (pow(i, 4) - 2) + b
        }
        
        /// t^5
        public static let quintic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            var i = t / (d / 2)
            if i < 1 { return c / 2 * pow(i, 5) }
            i -= 2
            return c / 2 * (pow(i, 5) + 2) + b
        }
        
        /// sin(t)
        public static let sinusodial = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            let i = cos(.pi * t / d) - 1
            return (-c) / 2 * i + c + b
        }
        
        /// 2^t
        public static let exponential = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t == 0 { return b }
            if t == d { return b + c }
            var i = t / (d / 2)
            if i < 1 { return c / 2 * pow(2, 10 * (i - 1)) + b - c * 0.0005 }
            i -= 1
            return c / 2 * 1.0005 * (-pow(2, -10 * i) + 2) + b
        }
        
        ///sqrt(1-t^2)
        public static let circular = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            var i = t / (d / 2)
            if i < 1 { return (-c) / 2 * (sqrt(1 - pow(i, 2)) - 1) + b }
            i -= 2
            return c / 2 * (sqrt(1 - pow(i, 2)) + 1) + b
        }
        
        ///指数衰减正弦曲线
        public static let elastic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t == 0 { return 0 }
            var i = t / (d / 2)
            if i == 2 { return b + c }
            let p = d * 0.3 * 1.5
            var s: Double = 0
            let a = c
            if a < abs(c) {
                s = p / 4
            } else {
                s = p / (.pi * 2) * (a == 0 ? 0 : asin(c / a))
            }
            i -= 1
            if i < 1 {
                return -0.5 * (a * pow(2, 10 * i) * sin((i * d - s) * (.pi * 2) / p)) + b
            } else {
                return a * pow(2, -10 * i) * sin((i * d - s) * (.pi * 2) / p) * 0.5 + c + b
            }
        }
        
        public static let back = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            var i = t / (d / 2)
            let s: Double = 1.70158 * 1.525
            if i < 1 { return c / 2 * (pow(i, 2) * ((s + 1) * i - s) + b) }
            i -= 2
            return c / 2 * (pow(i, 2) * ((s + 1) * i + s) + 2) + b
        }
        
        public static let bounce = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return In.bounce.function(t * 2, 0, c, d) * 0.5 + b
            } else {
                return Out.bounce.function(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
            }
        }
    }
    
    public enum OutIn {
        
        /// t^2
        public static let quadratic = TweenEasing { t, b, c, d in
            if d == 0 { return 0 }
            if t < d / 2 {
                return Out.quadratic.function(t, b, c / 2, d)
            } else {
                return In.quadratic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// t^3
        public static let cubic = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return In.cubic.function(t, b, c / 2, d)
            } else {
                return Out.cubic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// t^4
        public static let quartic = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.quadratic.function(t, b, c / 2, d)
            } else {
                return In.quadratic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// t^5
        public static let quintic = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.quintic.function(t, b, c / 2, d)
            } else {
                return In.quintic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// sin(t)
        public static let sinusodial = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.sinusodial.function(t, b, c / 2, d)
            } else {
                return In.sinusodial.function(t, b + c / 2, c / 2, d)
            }
        }
        
        /// 2^t
        public static let exponential = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.exponential.function(t, b, c / 2, d)
            } else {
                return In.exponential.function(t, b + c / 2, c / 2, d)
            }
        }
        
        ///sqrt(1-t^2)
        public static let circular = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.circular.function(t, b, c / 2, d)
            } else {
                return In.circular.function(t, b + c / 2, c / 2, d)
            }
        }
        
        ///指数衰减正弦曲线
        public static let elastic = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.elastic.function(t, b, c / 2, d)
            } else {
                return In.elastic.function(t, b + c / 2, c / 2, d)
            }
        }
        
        public static let back = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.back.function(t, b, c / 2, d)
            } else {
                return In.back.function(t, b + c / 2, c / 2, d)
            }
        }
        
        public static let bounce = TweenEasing { t, b, c, d in
            if t < d / 2 {
                return Out.bounce.function(t * 2, 0, c, d) * 0.5 + b
            } else {
                return In.bounce.function(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
            }
        }
    }
    
}
