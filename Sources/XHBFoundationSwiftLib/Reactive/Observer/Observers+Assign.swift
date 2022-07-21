//
//  Observers+Assign.swift
//  
//
//  Created by xiehongbiao on 2022/7/6.
//

import Foundation

extension Observers {
    
    final public class Assign<Root, Input>: Observer, Cancellable {
        
        public typealias Input = Input
        public typealias Failure = Never
        
        public let identifier: UUID = .init()
        public var object: Root?
        public let keyPath: ReferenceWritableKeyPath<Root, Input>
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }
        
        public func receive(_ signal: Signal) {
            signal.request(.unlimited)
        }
        
        public func receive(_ signal: Observers.Completion<Never>) {}
        
        public func receive(_ input: Input) {
            self.object?[keyPath: self.keyPath] = input
        }
        
        public func cancel() {
            object = nil
        }
    }
}

extension Observable where Failure == Never {
    
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        let assign: Observers.Assign = .init(object: object, keyPath: keyPath)
        subscribe(assign)
        return .init(assign)
    }
    
}
