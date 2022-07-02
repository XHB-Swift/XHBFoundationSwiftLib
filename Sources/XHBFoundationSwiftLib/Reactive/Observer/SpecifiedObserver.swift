//
//  SpecifiedObserver.swift
//  
//
//  Created by 谢鸿标 on 2022/7/2.
//

import Foundation

public final class SpecifiedObserver<Observer: AnyObject>: AnyObserver {
    
    public override func notify<Value>(value: Value) {
        guard let ob = self.base as? Observer,
              let closure = closure as? ObserverClosure<Observer, Value> else {
            return
        }
        closure(ob, value)
    }
}
