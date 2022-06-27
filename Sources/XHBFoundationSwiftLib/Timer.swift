//
//  Timer.swift
//  
//
//  Created by 谢鸿标 on 2022/6/25.
//

import Foundation

public typealias TimerUpdateAction = (TimeInterval)->Void

extension Timer {
    
    public class func scheduled(interval: TimeInterval,
                                loopInCommonModes: Bool,
                                repeats: Bool,
                                action: @escaping TimerUpdateAction) -> Timer {
        
        let timer = Timer.scheduledTimer(timeInterval: interval,
                                         target: self,
                                         selector: #selector(timerAction(_:)),
                                         userInfo: action,
                                         repeats: repeats)
        
        if loopInCommonModes {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        return timer
    }
    
    @objc private class func timerAction(_ sender: Timer) {
        guard let action = sender.userInfo as? TimerUpdateAction else { return }
        action(sender.timeInterval)
    }
}

#if os(iOS)

import UIKit

extension CADisplayLink {
    
    private static var UpdatedActionKey: Void?
    
    private var updateAction: TimerUpdateAction? {
        set {
            if newValue == nil {
                print("Set CADisplayLink updateAction is nil")
            }
            objc_setAssociatedObject(self, &CADisplayLink.UpdatedActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            let action = objc_getAssociatedObject(self, &CADisplayLink.UpdatedActionKey) as? TimerUpdateAction
            if action == nil {
                print("Get CADisplayLink updateAction is nil")
            }
            return action
        }
    }
    
    public class func scheduled(loopInCommonModes: Bool,
                               action: @escaping TimerUpdateAction) -> CADisplayLink {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction(_:)))
        displayLink.updateAction = action
        displayLink.add(to: .current, forMode: loopInCommonModes ? .common : .default)
        return displayLink
    }
    
    @objc private class func displayLinkAction(_ sender: CADisplayLink) {
        sender.updateAction?(sender.duration)
    }
}

#endif
