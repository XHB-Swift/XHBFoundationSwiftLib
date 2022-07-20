//
//  DataStruct+SingleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

extension DataStruct {
    
    public struct SingleLinkedList<Element>: LinkedListModule {
        
        internal typealias _Storage = _LinkedList<Element>
        
        internal var _storage: _Storage
        
        public var count: Int { innerCount }
        public var isEmpty: Bool { count == 0 }
        
        private var innerCount: Int = 0
        
        public init() {
            _storage = .init()
        }
        
        public init<S: Sequence>(_ s: S) where Element == S.Element {
            _storage = .init(s)
        }
    }
}

extension DataStruct.SingleLinkedList: LinkedListModule {
    
    public subscript(_ index: Int) -> Element? {
        return _storage._find(index)?.storage
    }
    
    public func append(_ element: Element) {
        _storage._append(.init(storage: element, next: nil))
    }
    
    public func insert(_ element: Element, at index: Int) {
        _storage._insert(.init(storage: element, next: nil), at: index)
    }
    
    @discardableResult
    public func remove(at index: Int) -> Element? {
        return _storage._remove(index)?.storage
    }
    
    public func append<S>(contentsof s: S) where S : Sequence, Element == S.Element {
        <#code#>
    }
    
    public func removeFirst() -> Element? {
        <#code#>
    }
    
    public func removeLast() -> Element? {
        <#code#>
    }
    
    public func removeAll() {
        <#code#>
    }
    
}

extension DataStruct.SingleLinkedList: Swift.Sequence {
    
    public typealias Element = Element
    
    public struct Iterator: IteratorProtocol {
        
        internal var _next: _Storage._Node?
        
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
