//
//  DataStruct+Queue.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension DataStruct {
    
    public struct Queue<Element> {
        
        private var storage: ContiguousArray<Element> = .init()
        private var innerCount = 0
        
        public var isEmpty: Bool { return innerCount == 0 }
        public var count: Int { return innerCount }
        
        mutating public func enqueue(_ element: Element) {
            storage.append(element)
            innerCount += 1
        }
        
        mutating public func dequeue() -> Element? {
            let first = storage.first
            if storage.isNotEmpty {
                _ = storage.removeFirst()
                innerCount -= 1
            }
            return first
        }
        
        public func peek() -> Element? {
            return storage.first
        }
        
        public mutating func clear() {
            if isEmpty { return }
            storage.removeAll()
            innerCount = 0
        }
        
    }
}

extension DataStruct.Queue: Swift.Sequence {
    
    public typealias Element = Element
    public typealias Iterator = Swift.AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        var i = 0
        var innerCount = count
        return .init {
            if innerCount == 0 { return nil }
            defer {
                innerCount -= 1
                i += 1
            }
            return self.storage[i]
        }
    }
}
