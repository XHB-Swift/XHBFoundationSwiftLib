//
//  DataStruct+LoopSingleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

extension DataStruct {
    
    public struct LoopSingleLinkedList<Element> {
        
        internal typealias _Storage = _SingleLinkedListStorage<Element>
        
        internal var _storage: _Storage
        
        public init() {
            _storage = .init()
        }
        
        public init<S: Sequence>(_ s: S) where Element == S.Element {
            _storage = .init(s)
            _storage.loop = true
        }
    }
}

extension DataStruct.LoopSingleLinkedList: LinkedListModule {
    
    public var first: Element? { _storage.front?.storage }
    public var last: Element? { _storage.rear?.storage }
    public var count: Int { _storage.count }
    public var isEmpty: Bool { _storage.isEmpty }
    
    public subscript(index: Int) -> Element? {
        set {
            guard let element = newValue else { return }
            guard let target = _storage._find(index) else {
                append(element)
                return
            }
            target.storage = element
        }
        get {
            return _storage._find(index)?.storage
        }
    }
    
    public func append(_ element: Element) {
        _storage._append(.init(storage: element, next: nil))
    }
    
    public func append<S>(contentsof s: S) where S : Sequence, Element == S.Element {
        s.forEach { append($0) }
    }
    
    public func insert(_ element: Element, at index: Int) {
        _storage._insert(.init(storage: element, next: nil), at: index)
    }
    
    public func removeFirst() -> Element? {
        return _storage._removeFirst()?.storage
    }
    
    public func removeLast() -> Element? {
        return _storage._removeLast()?.storage
    }
    
    public func remove(at index: Int) -> Element? {
        return _storage._remove(index)?.storage
    }
    
    public func removeAll() {
        _storage._removeAll()
    }
}

extension DataStruct.LoopSingleLinkedList: Swift.Sequence {
    
    public typealias Element = Element
    
    public struct Iterator: IteratorProtocol {
        
        internal var _front: _Storage._SingleNode<Element>?
        internal var _next: _Storage._SingleNode<Element>?
        internal var _stop = false
        
        internal init(_storage: _Storage?) {
            self._front = _storage?.front
            self._next = _front
        }
        
        mutating public func next() -> Element? {
            if _stop { return nil }
            let storage = _next?.storage
            _next = _next?.next
            _stop = (_front === _next)
            return storage
        }
    }
    
    public func makeIterator() -> Iterator {
        return .init(_storage: _storage)
    }
}

extension DataStruct.LoopSingleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "->") }
}
