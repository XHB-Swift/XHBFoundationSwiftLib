//
//  StateMachine.swift
//  
//
//  Created by 谢鸿标 on 2022/6/25.
//

import Foundation

public typealias TransitionCompletion<S> = (_ state: S) -> Void

public struct Transition<E,S> {
    
    public let event: E
    public let from: S
    public let to: S
    
    private let willChangeAction: TransitionCompletion<S>?
    private let didChangeAction: TransitionCompletion<S>?
    
    public init(event: E,
                from: S,
                to: S,
                willChangeAction: TransitionCompletion<S>? = nil,
                didChangeAction: TransitionCompletion<S>? = nil) {
        self.event = event
        self.from = from
        self.to = to
        self.willChangeAction = willChangeAction
        self.didChangeAction = didChangeAction
    }
    
    public func willChangeState() {
        self.willChangeAction?(self.from)
    }
    
    public func didChangeState() {
        self.didChangeAction?(self.to)
    }
    
}

public final class StateMachine<E: Hashable, S: Hashable> {
    
    private(set) var currentState: S
    
    private let lockQueue = DispatchQueue(label: "com.xhb.state.machine.lock.queue")
    private let machineQueue = DispatchQueue(label: "com.xhb.state.machine.work.queue")
    private let executionQueue: DispatchQueue
    
    private var eventTransitionInfo = Dictionary<E, [Transition<E,S>]>()
    
    
    public init(state: S, executionQueue: DispatchQueue = .main) {
        self.currentState = state
        self.executionQueue = executionQueue
    }
    
    public func register(event: E, from: S, to: S, completion: TransitionCompletion<S>? = nil) {
        
        self.lockQueue.sync {
            let transition = Transition<E, S>(event: event, from: from, to: to, didChangeAction:completion)
            if let transitions = self.eventTransitionInfo[event] {
                
                let sameActions = transitions.filter { $0.from == from }
                if sameActions.isNotEmpty {
                    fatalError("Registered Same Transitions")
                } else {
                    self.eventTransitionInfo[event]?.append(transition)
                }
            } else {
                
                self.eventTransitionInfo[event] = [transition]
            }
        }
    }
    
    public func trigger(event: E, execution: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        
        var transitions: Array<Transition<E,S>>?
        
        self.lockQueue.sync {
            transitions = self.eventTransitionInfo[event]
        }
        
        guard let transitions = transitions else { return }

        
        self.machineQueue.async {
            
            let perfomTransitions = transitions.filter { $0.from == self.currentState }
            if perfomTransitions.isEmpty {
                self.executionQueue.async {
                    completion?(false)
                }
                return
            }
            assert(perfomTransitions.count == 1, "Found multiple transitions.")
            
            guard let performTransition = perfomTransitions.first else { return }
            
            self.executionQueue.async {
                performTransition.willChangeState()
                execution?()
            }
            
            self.currentState = performTransition.to
            
            self.executionQueue.async {
                performTransition.didChangeState()
                completion?(true)
            }
        }
    }
}
