//
//  DataStruct+DoubleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/20.
//

import Foundation

extension DataStruct {
    
    public struct DoubleLinkedList<Element> {
        
        internal typealias ElementNode = DoubleLinkedListNode<Element>
        
        private var front: ElementNode?
        private var rear: ElementNode?
        private var _count: Int = 0
        private var _reversed = false
        
        public init() {}
        
        public init<S: Sequence>(_ s: S) where S.Element == Element {
            var iterator = s.makeIterator()
            var prior: ElementNode?
            while let next = iterator.next() {
                _count += 1
                let node: ElementNode = .init(storage: next, next: nil, prior: nil)
                if _count == 1 {
                    front = node
                    prior = node
                } else {
                    node.prior = prior
                    prior?.next = node
                    prior = node
                }
                rear = node
            }
        }
        
        private func _find(_ index: Int) -> ElementNode? {
            if !(0..<_count).contains(index) { return nil }
            if index == 0 { return front }
            if index == _count - 1 { return rear }
            var node: DoubleLinkedListNode<Element>?
            var i = 1
            while let next = _reversed ? rear?.prior : front?.next,
                  i < _count - 2 {
                if i == index {
                    node = next
                    break
                }
                i += 1
            }
            return node
        }
        
        private mutating func _append(_ node: ElementNode) {
            if isEmpty {
                front = node
            }
            rear?.next = node
            node.prior = rear
            rear = node
            _count += 1
        }
        
        private mutating func _insert(_ node: ElementNode, at index: Int) {
            guard let target = _find(index) else {
                _append(node)
                return
            }
            let p = target.prior
            p?.next = node
            node.prior = p
            target.prior = node
            node.next = target
            _count += 1
        }
        
        private mutating func _removeFirst() -> ElementNode? {
            if isEmpty { return nil }
            defer {
                _count -= 1
                if _reversed {
                    rear = rear?.prior
                } else {
                    front = front?.next
                }
            }
            return front
        }
        
        private mutating func _removeLast() -> ElementNode? {
            if isEmpty { return nil }
            defer {
                _count -= 1
                if _reversed {
                    front = front?.next
                } else {
                    rear = rear?.prior
                }
            }
            return rear
        }
        
        private mutating func _remove(_ index: Int) -> ElementNode? {
            if isEmpty { return nil }
            if index == _count - 1 { return _removeLast() }
            if index == 0 { return _removeFirst() }
            let target = _find(index)
            let p = target?.prior
            let n = target?.next
            p?.next = n
            n?.prior = p
            _count -= 1
            return target
        }
    }
}

extension DataStruct.DoubleLinkedList {
    
    public mutating func append(_ element: Element) {
        _append(.init(storage: element, next: nil, prior: nil))
    }
    
    public mutating func append<S: Sequence>(contentsof s: S) where S.Element == Element {
        var iterator = s.makeIterator()
        while let next = iterator.next() {
            _append(.init(storage: next, next: nil, prior: nil))
        }
    }
    
    @discardableResult
    public mutating func removeFirst() -> Element? {
        return _removeFirst()?.storage
    }
    
    @discardableResult
    public mutating func removeLast() -> Element? {
        return _removeLast()?.storage
    }
    
    public mutating func insert(_ element: Element, at index: Int) {
        _insert(.init(storage: element, next: nil, prior: nil), at: index)
    }
    
    public mutating func insert<S: Sequence>(_ elements: S, at index: Int) where S.Element == Element {
        guard let target = _find(index) else {
            append(contentsof: elements)
            return
        }
        var newLinked: DataStruct.DoubleLinkedList<Element> = .init(elements)
        let p = target.prior
        p?.next = newLinked.front
        newLinked.front = p
        target.prior = newLinked.rear
        newLinked.rear?.next = target
    }
    
    public mutating func update(_ element: Element, at index: Int) {
        guard let target = _find(index) else {
            append(element)
            return
        }
        target.storage = element
    }
    
    public mutating func removeAll() {
        front = nil
        rear = nil
        _count = 0
    }
    
    public mutating func reversed() {
        _reversed = !_reversed
    }
    
    subscript(position: Int) -> Element? {
        return _find(position)?.storage
    }
}

extension DataStruct.DoubleLinkedList where Element: Equatable {
    
    public func contains(_ element: Element) -> Bool {
        var iterator = makeIterator()
        while let next = iterator.next() {
            if next == element { return true }
        }
        return false
    }
}

extension DataStruct.DoubleLinkedList: Sequence {

    public typealias Index = Int
    public typealias Element = Element

    public var count: Int { return _count }
    public var isEmpty: Bool { _count == 0 }

    public struct Iterator: IteratorProtocol {

        internal var _front: ElementNode?
        internal var _rear: ElementNode?
        internal var _next: ElementNode?
        internal var _reversed: Bool

        internal init(_base: DataStruct.DoubleLinkedList<Element>) {
            self._front = _base.front
            self._rear = _base.rear
            self._next = _base._reversed ? _base.rear : _base.front
            self._reversed = _base._reversed
        }

        mutating public func next() -> Element? {
            let storage = _next?.storage
            _next = _reversed ? _next?.prior : _next?.next
            return storage
        }
    }

    public func makeIterator() -> Iterator {
        return .init(_base: self)
    }
}

extension DataStruct.DoubleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "<->") }
    
}
