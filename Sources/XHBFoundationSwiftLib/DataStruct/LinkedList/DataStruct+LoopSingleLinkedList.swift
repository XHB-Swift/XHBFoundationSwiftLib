//
//  DataStruct+LoopSingleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

extension DataStruct {
    
    public struct LoopSingleLinkedList<Element> {
        
        internal var front: SingleLinkedListNode<Element>?
        internal var rear: SingleLinkedListNode<Element>?
        
        public var count: Int { innerCount }
        public var isEmpty: Bool { count == 0 }
        
        private var innerCount: Int = 0
        
        public init<S: Sequence>(_ s: S) where Element == S.Element {
            var iterator = s.makeIterator()
            while let element = iterator.next() {
                let node = SingleLinkedListNode(storage: element, next: nil)
                innerCount += 1
                if innerCount == 1 {
                    front = node
                } else {
                    rear?.next = node
                }
                rear = node
            }
            rear?.next = front
        }
        
        mutating public func insert(_ element: Element, at index: Int) {
            let new = SingleLinkedListNode<Element>(storage: element, next: nil)
            if index == 0 {
                new.next = front
                front = new
                rear?.next = front
                innerCount += 1
            } else if !(0..<innerCount).contains(index) {
                rear?.next = new
                rear = new
                rear?.next = front
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
                rear?.next = front
                innerCount -= 1
                return front?.storage
            }
            var tmp = front
            var i = 1
            while let next = tmp?.next, next !== front {
                if i == index {
                    let n = next.next
                    tmp?.next = n
                    next.next = nil
                    if i == innerCount - 1 {
                        rear = tmp
                        rear?.next = front
                    }
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

extension DataStruct.LoopSingleLinkedList: Swift.Sequence {
    
    public typealias Element = Element
    
    public struct Iterator: IteratorProtocol {
        
        internal var _storage: SingleLinkedListNode<Element>?
        internal var _begin: SingleLinkedListNode<Element>?
        internal var _next: SingleLinkedListNode<Element>?
        internal var _stop = false
        
        internal init(_begin: SingleLinkedListNode<Element>?) {
            self._storage = _begin
            self._begin = _begin
            self._next = _begin?.next
        }
        
        mutating public func next() -> Element? {
            if _stop { return nil }
            let storage = _storage?.storage
            _storage = _storage?.next
            _stop = (_begin === _storage)
            return storage
        }
    }
    
    public func makeIterator() -> Iterator {
        return .init(_begin: front)
    }
}

extension DataStruct.LoopSingleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "->") }
}
