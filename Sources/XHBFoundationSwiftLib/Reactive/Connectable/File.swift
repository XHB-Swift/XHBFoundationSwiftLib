//
//  Timer+Connectable.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

extension Timer {
    
    final public class Observation: ConnectableObservable {
        
        public typealias Output = Date
        public typealias Failure = Never
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            
        }
        
        public func connect() -> Cancellable {
            
        }
    }
    
}
