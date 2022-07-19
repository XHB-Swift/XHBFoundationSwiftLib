//
//  DataStruct+Stack.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension DataStruct {
    
    public struct Stack<Element> {
        
        private var storage: ContiguousArray<Element>
        
        public var count: Int { return storage.count }
        public var isEmpty: Bool { return storage.isEmpty }
        
        public init() {
            storage = .init()
        }
        
        mutating public func push(_ element: Element) {
            storage.append(element)
        }
        
        mutating public func pop() -> Element? {
            let last = storage.last
            if storage.isNotEmpty {
                _ = storage.removeLast()
            }
            return last
        }
        
        public func peek() -> Element? {
            return storage.last
        }
        
        mutating public func clear() {
            if isEmpty { return }
            storage.removeAll()
        }
    }
}

extension DataStruct.Stack: Swift.Sequence {
    
    public typealias Element = Element
    public typealias Iterator = AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        return .init(storage.reversed().makeIterator())
    }
}

extension DataStruct.Stack: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: " ") }
    
}
