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
        private var innerCount: Int
        
        public var count: Int { return innerCount }
        public var isEmpty: Bool { return count == 0 }
        
        init() {
            storage = .init()
            innerCount = 0
        }
        
        mutating public func push(_ element: Element) {
            storage.append(element)
            innerCount += 1
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
            innerCount = 0
        }
    }
}

extension DataStruct.Stack: Sequence {
    
    public typealias Element = Element
    public typealias Iterator = AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        var i = innerCount - 1
        var innerCount = innerCount
        return .init {
            if innerCount == 0 { return nil }
            defer {
                innerCount -= 1
                i -= 1
            }
            return self.storage[i]
        }
    }
}
