//
//  AnyCancellable.swift
//  
//
//  Created by xiehongbiao on 2022/7/7.
//

import Foundation

final public class AnyCancellable: Cancellable, Hashable {
    
    private var canceller: Cancellable?
    private var cancelClosure: (() -> Void)?
    
    public init(_ cancel: @escaping () -> Void) {
        self.cancelClosure = cancel
    }
    
    public init<C: Cancellable>(_ canceller: C) {
        self.canceller = canceller
    }
    
    public func cancel() {
        self.canceller?.cancel()
        self.cancelClosure?()
    }
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
