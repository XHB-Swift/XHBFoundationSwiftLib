//
//  DataStruct+Queue.swift
//  
//
//  Created by xiehongbiao on 2022/7/12.
//

import Foundation

extension DataStruct {
    
    public struct Queue<Element> {
        
        private var _storage: DataStruct.DoubleLinkedList<Element> = .init()
        
        public var isEmpty: Bool { _storage.isEmpty }
        public var count: Int { _storage.count }
        
        public func enqueue(_ element: Element) {
            _storage.append(element)
        }
        
        public func dequeue() -> Element? {
            let first = _storage.first
            if !isEmpty {
                _ = _storage.removeFirst()
            }
            return first
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

extension DataStruct.Queue: Swift.Sequence {
    
    public typealias Element = Element
    public typealias Iterator = DataStruct.DoubleLinkedList<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        return _storage.makeIterator()
    }
}

extension DataStruct.Queue: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: " ") }
}
