//
//  DataStruct+SingleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

extension DataStruct {
    
    public struct SingleLinkedList<Element> {
        
        private var front: LinkedListNode<Element>?
        private var rear: LinkedListNode<Element>?
        
        public var count: Int { innerCount }
        public var isEmpty: Bool { count == 0 }
        
        private var innerCount: Int = 0
        
        public init() {}
        
        public init<S: Sequence>(_ s: S) where Element == S.Element {
            var iterator = s.makeIterator()
            while let element = iterator.next() {
                let node = LinkedListNode(storage: element, next: nil)
                innerCount += 1
                if innerCount == 1 {
                    front = node
                } else {
                    rear?.next = node
                }
                rear = node
            }
        }
        
        public subscript(_ index: Int) -> Element? {
            if !(0..<innerCount).contains(index) { return nil }
            if index == 0 { return front?.storage }
            if index == innerCount - 1 { return rear?.storage }
            var tmp = front
            var i = 1
            while let next = tmp?.next {
                if i == index { return next.storage }
                tmp = next
                i += 1
            }
            return nil
        }
        
        mutating public func add(_ element: Element) {
            insert(element, at: innerCount - 1)
        }
        
        mutating public func insert(_ element: Element, at index: Int) {
            let new = LinkedListNode<Element>(storage: element, next: nil)
            if index == 0 {
                new.next = front
                front = new
                innerCount += 1
            } else if !(0..<innerCount).contains(index) {
                rear?.next = new
                rear = new
                innerCount += 1
            } else {
                var tmp = front
                var i = 1
                while let next = tmp?.next {
                    if i == index {
                        let n = tmp?.next
                        tmp?.next = new
                        new.next = n
                        innerCount += 1
                        break
                    }
                    tmp = next
                    i += 1
                }
            }
        }
        
        @discardableResult
        mutating public func remove(at index: Int) -> Element? {
            if !(0..<innerCount).contains(index) { return nil }
            if index == 0 {
                let next = front?.next
                front?.next = nil
                front = next
                innerCount -= 1
                return front?.storage
            }
            var tmp = front
            var i = 1
            while let next = tmp?.next {
                if i == index {
                    let n = next.next
                    tmp?.next = n
                    next.next = nil
                    innerCount -= 1
                    return next.storage
                }
                tmp = next
                i += 1
            }
            return nil
        }
    }
}

extension DataStruct.SingleLinkedList: Swift.Sequence {
    
    public typealias Element = Element
    public typealias Iterator = Swift.AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        
        var temp = front
        return .init {
            defer {
                temp = temp?.next
            }
            return temp?.storage
        }
    }
}

extension DataStruct.SingleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "->") }
}
