//
//  DataStruct+SingleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

extension DataStruct {
    
    public struct SingleLinkedList<Element> {
        
        internal typealias _Storage = _SingleLinkedListStorage<Element>
        
        internal var _storage: _Storage
        
        public init() {
            _storage = .init()
        }
        
        public init<S: Sequence>(_ s: S) where Element == S.Element {
            _storage = .init(s)
        }
    }
}

extension DataStruct.SingleLinkedList: LinkedListModule {
    
    public var count: Int { _storage.count }
    public var isEmpty: Bool { _storage.isEmpty }
    
    public subscript(_ index: Int) -> Element? {
        set {
            guard let element = newValue else { return }
            guard let node = _storage._find(index) else {
                append(element)
                return
            }
            node.storage = element
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
    
    @discardableResult
    public func remove(at index: Int) -> Element? {
        return _storage._remove(index)?.storage
    }
    
    @discardableResult
    public func removeFirst() -> Element? {
        return _storage._removeFirst()?.storage
    }
    
    @discardableResult
    public func removeLast() -> Element? {
        return _storage._removeLast()?.storage
    }
    
    public func removeAll() {
        _storage._removeAll()
    }
}

extension DataStruct.SingleLinkedList: Swift.Sequence {
    
    public typealias Element = Element
    
    public struct Iterator: IteratorProtocol {
        
        internal var _next: _Storage._SingleNode<Element>?
        
        internal init(_storage: _Storage) {
            _next = _storage.front?.next
        }
        
        public mutating func next() -> Element? {
            defer {
                _next = _next?.next
            }
            return _next?.storage
        }
    }
    
    public func makeIterator() -> Iterator {
        return .init(_storage: _storage)
    }
}

extension DataStruct.SingleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "->") }
}
