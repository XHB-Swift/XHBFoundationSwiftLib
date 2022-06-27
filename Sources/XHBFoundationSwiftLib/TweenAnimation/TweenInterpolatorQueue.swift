//
//  TweenInterpolatorQueue.swift
//  CodeRecord-Swift
//
//  Created by 谢鸿标 on 2022/5/15.
//  Copyright © 2022 谢鸿标. All rights reserved.
//

import Foundation

public typealias TweenAnimation = (_ value: TweenValue) -> Void
public typealias TweenCompletion = () -> Void
private typealias TweenActionAnimation = (_ value: TweenValue, _ keyPath: AnyKeyPath) -> Void
private typealias TweenActionCompletion = (TweenAction) -> Void

private class TweenAction {
    
    internal var interpolator: TweenInterpolator
    internal var keyPath: AnyKeyPath
    internal var animation: TweenActionAnimation?
    internal var completion: TweenActionCompletion?
    
    deinit {
        print("released")
    }
    
    internal init(interpolator: TweenInterpolator,
                  for keyPath: AnyKeyPath,
                  animation: TweenActionAnimation? = nil,
                  completion: TweenActionCompletion? = nil) {
        
        self.interpolator = interpolator
        self.keyPath = keyPath
        self.interpolator.delegate = self
        self.animation = animation
        self.completion = completion
    }
}

extension TweenAction : TweenInterpolatorDelegate {
    
    func interpolator(didFinish interpolator: TweenInterpolator) {
        self.completion?(self)
    }
    
    func interpolator(_ interpolator: TweenInterpolator, didUpdateToValue value: TweenValue) {
        self.animation?(value, self.keyPath)
    }
    
}

public protocol TweenInterpolatorQueueDelegate: AnyObject {
    
    func queue(didFinish: TweenInterpolatorQueue)
    func queue(_ queue: TweenInterpolatorQueue, didUpdateFor keyPath: AnyKeyPath, to value: TweenValue)
}

public final class TweenInterpolatorQueue {
    
    public weak var delegate: TweenInterpolatorQueueDelegate?
    
    private var scheduler: TweenScheduler
    private var actions: Array<TweenAction>
    
    public init() {
        self.scheduler = TweenScheduler()
        self.actions = Array<TweenAction>()
        self.scheduler.delegate = self
    }
    
    public func add<T>(interpolator: TweenInterpolator,
                       for keyPath:PartialKeyPath<T>,
                       animation: @escaping TweenAnimation,
                       completion: TweenCompletion? = nil) {
        let action = TweenAction(interpolator: interpolator,
                                 for: keyPath) { [weak self] value, keyPath in
            self?.handleUpdated(value: value, for: keyPath, animation: animation)
        } completion: { [weak self] action in
            self?.handleFinished(action: action, completion: completion)
        }
        self.actions.append(action)
    }
    
    public func playAnimation() {
        self.scheduler.startScheduler()
    }
    
    public func stopAnimation() {
        self.scheduler.stopScheduler()
    }
    
    private func handleUpdated(value: TweenValue, for keyPath: AnyKeyPath, animation: TweenAnimation) {
        animation(value)
        self.delegate?.queue(self, didUpdateFor: keyPath, to: value)
    }
    
    private func handleFinished(action: TweenAction, completion: TweenCompletion? = nil) {
        self.actions.removeFirst()
        completion?()
        self.delegate?.queue(didFinish: self)
        self.stopAnimation()
    }
}

extension TweenInterpolatorQueue : TweenSchedulerDelegate {
    
    public func scheduler(_ scheduler: TweenScheduler, didUpdateFor duration: TimeInterval) {
        if self.actions.isEmpty {
            self.stopAnimation()
            return
        }
        self.actions.first?.interpolator.moveTo(time: duration)
    }
}

#if os(iOS)

import UIKit

extension UIView {
    
    private static var TweenEngineKey: Void?
    
    private var tweenEngine: TweenInterpolatorQueue? {
        set {
            objc_setAssociatedObject(self, &UIView.TweenEngineKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var engine = objc_getAssociatedObject(self, &UIView.TweenEngineKey) as? TweenInterpolatorQueue
            if engine == nil {
                engine = TweenInterpolatorQueue()
                self.tweenEngine = engine
            }
            return engine
        }
    }
    
    public func tweenAnimation(for keyPath: PartialKeyPath<UIView>,
                               duration: TimeInterval,
                               easing: TweenEasing,
                               from: TweenValue? = nil,
                               to: TweenValue,
                               reversed: Bool = false,
                               completion: TweenCompletion? = nil) {
        guard let v0 = from ?? self[keyPath: keyPath] as? TweenValue else { return }
        let interpolator = TweenInterpolator(easing: easing, duration: duration, from: v0, to: to)
        self.tweenEngine?.add(interpolator: interpolator,
                              for: keyPath,
                              animation: { [weak self] value in
            self?.update(value: value, for: keyPath)
        }, completion: { [weak self] in
            guard reversed else { return }
            self?.update(value: v0, for: keyPath)
        })
        self.tweenEngine?.playAnimation()
    }
    
    private func update(value: TweenValue, for keyPath: AnyKeyPath) {
        //背景色
        if let _ = keyPath as? ReferenceWritableKeyPath<UIView, UIColor?> {
            self.backgroundColor = value as? UIColor
        }
        //透明度
        if let _ = keyPath as? ReferenceWritableKeyPath<UIView, CGFloat>,
            let a = value as? CGFloat {
            self.alpha = a
        }
        //frame
        if let _ = keyPath as? ReferenceWritableKeyPath<UIView, CGRect>,
            let rect = value as? CGRect {
            self.frame = rect
        }
    }
}

#endif
