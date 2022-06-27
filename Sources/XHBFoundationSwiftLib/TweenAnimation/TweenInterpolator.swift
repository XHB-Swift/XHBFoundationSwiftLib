//
//  TweenInterpolator.swift
//  CodeRecord-Swift
//
//  Created by 谢鸿标 on 2022/5/15.
//  Copyright © 2022 谢鸿标. All rights reserved.
//

import Foundation

public protocol TweenInterpolatorDelegate: AnyObject {
    
    func interpolator(didFinish interpolator: TweenInterpolator)
    func interpolator(_ interpolator: TweenInterpolator, didUpdateToValue value: TweenValue)
}

public final class TweenInterpolator {
    
    public weak var delegate: TweenInterpolatorDelegate?
    
    private var easing: TweenEasing
    private var duration: TimeInterval
    
    private var from: TweenValue
    private var to: TweenValue
    private var v0: [Double]
    private var v1: [Double]
    
    public init(easing: TweenEasing, duration: TimeInterval, from: TweenValue, to: TweenValue) {
        self.easing = easing
        self.duration = duration
        
        self.from = from
        self.to = to
        self.v0 = from.values
        self.v1 = to.values
    }
    
    public func moveTo(time: TimeInterval) {
        if self.didMoveToEnd {
            self.delegate?.interpolator(didFinish: self)
            return
        }
        if time >= self.duration {
            self.v0 = self.v1
        } else {
            self .moveToNext(t: time, d: (self.duration - time))
        }
        self.delegate?.interpolator(self, didUpdateToValue: self.from)
    }
    
    private var didMoveToEnd: Bool {
        
        if self.v0.count != self.v1.count { return false }
        let indecies = (0..<self.v0.count)
        var isEqual = true
        for index in indecies {
            let v0 = self.v0[index]
            let v1 = self.v1[index]
            if v0 != v1 {
                isEqual = false
                break
            }
        }
        return isEqual
    }
    
    private func moveToNext(t: Double, d: Double) {
        
        if self.v0.count != self.v1.count { return }
        let indecies = (0..<self.v0.count)
        let function = self.easing.function
        for index in indecies {
            let v0 = self.v0[index]
            let v1 = self.v1[index]
            let direction = v1 > v0
            if v0 == v1 { continue }
            let b = function(t, v0, v1 - v0, d)
            self.v0[index] = (direction ? max(b, v0) : max(b, v1))
        }
    }
}

