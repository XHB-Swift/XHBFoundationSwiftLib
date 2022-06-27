//
//  TweenScheduler.swift
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

public protocol TweenSchedulerDelegate: AnyObject {
    
    func scheduler(_ scheduler: TweenScheduler, didUpdateFor duration: TimeInterval)
}

public final class TweenScheduler {
    
    public weak var delegate: TweenSchedulerDelegate?
    
    #if os(iOS)
    private var displayLink: CADisplayLink?
    #else
    private var displayLink: Timer?
    #endif
    private var lastTimestamp: TimeInterval = 0
    
    deinit {
        self.stopScheduler()
        NotificationCenter.default .removeObserver(self)
    }
    
    public init() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        #endif
    }
    
    @objc private func appDidBecomActive(_ sender: NSNotification) {
        self.lastTimestamp = 0
        #if os(iOS)
        self.displayLink?.isPaused = false
        #else
        self.displayLink?.fireDate = .distantPast
        #endif
    }
    
    @objc private func appWillResignActive(_ sender: NSNotification) {
        #if os(iOS)
        self.displayLink?.isPaused = true
        #else
        self.displayLink?.fireDate = .distantFuture
        #endif
        self.lastTimestamp = 0
    }
    
    public func startScheduler() {
        if self.displayLink != nil { return }
        
        #if os(iOS)
        self.displayLink = CADisplayLink.scheduled(loopInCommonModes: true,
                                                   action: { [weak self] time in
            self?.handleDisplayLinkAction()
        })
        #else
        self.displayLink = Timer.scheduled(interval: 0.001,
                                           loopInCommonModes: true,
                                           repeats: true,
                                           action: { [weak self] time in
            self?.handleDisplayLinkAction()
        })
        #endif
        self.lastTimestamp = CFAbsoluteTimeGetCurrent()
    }
    
    public func stopScheduler() {
        if self.displayLink != nil {
            self.displayLink?.invalidate()
            self.displayLink = nil
            self.lastTimestamp = 0
        }
    }
    
    private func handleDisplayLinkAction() {
        let duration = max(CFAbsoluteTimeGetCurrent() - self.lastTimestamp, 0)
        self.delegate?.scheduler(self, didUpdateFor: duration)
    }
    
}
