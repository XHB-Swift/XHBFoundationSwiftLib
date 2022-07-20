//
//  DataStruct+Stack.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension DataStruct {
    
    public struct Stack<Element> {
        
        internal var _storage: DataStruct.SingleLinkedList<Element>
        
        public var count: Int { _storage.count }
        public var isEmpty: Bool { _storage.isEmpty }
        
        public init() {
            _storage = .init()
        }
        
        public func push(_ element: Element) {
            _storage.insert(element, at: 0)
        }
        
        public func pop() -> Element? {
            let last = _storage.first
            if !isEmpty {
                _ = _storage.removeFirst()
            }
            return last
        }
        
        public func peek() -> Element? {
            return _storage.first
        }
        
        public func clear() {
            if isEmpty { return }
            _storage.removeAll()
        }
    }
}

extension DataStruct.Stack: Swift.Sequence {
    
    public typealias Element = Element
    public typealias Iterator = DataStruct.SingleLinkedList<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return _storage.makeIterator()
    }
}

extension DataStruct.Stack: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: " ") }
    
}
