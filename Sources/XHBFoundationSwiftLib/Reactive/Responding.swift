//
//  Responding.swift
//  
//
//  Created by xiehongbiao on 2022/7/5.
//

import Foundation

@dynamicMemberLookup
public struct Responding<Base> {
    
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
    
    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Property>) -> Responded<Base, Property> where Base: AnyObject {
        return .init(self.base) { target, value in
            target[keyPath: keyPath] = value
        }
    }
}

public struct Responded<Base, Input>: Observer {
    
    public typealias Input = Input
    public typealias Failure = Never
    
    private let responded: ClosureObserver<Input>
    
    public init<Target: AnyObject>(_ target: Target, _ responded: @escaping (Target, Input) -> Void) {
        weak var weakTarget = target
        self.responded = .init({ input in
            guard let strongTarget = weakTarget else { return }
            responded(strongTarget, input)
        })
    }
    
    public func receive(_ input: Input) {
        self.responded.receive(input)
    }
    
    public func receive(_ failure: Never) {}
}
