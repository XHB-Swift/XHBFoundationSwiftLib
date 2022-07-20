//
//  DataStruct+DoubleLinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/20.
//

import Foundation

extension DataStruct {
    
    public struct DoubleLinkedList<Element> {
        
        internal typealias _Storage = _DoubleLinkedListStorage<Element>
        
        internal var _storage: _Storage
        
        public init() {
            _storage = .init()
        }
        
        public init<S: Sequence>(_ s: S) where S.Element == Element {
            _storage = .init(s)
        }
    }
}

extension DataStruct.DoubleLinkedList: LinkedListModule {
    
    public var first: Element? { _storage.front?.storage }
    public var last: Element? { _storage.rear?.storage }
    
    public func append(_ element: Element) {
        _storage._append(.init(storage: element, next: nil, prior: nil))
    }
    
    public func append<S: Sequence>(contentsof s: S) where S.Element == Element {
        var iterator = s.makeIterator()
        while let next = iterator.next() {
            append(next)
        }
    }
    
    @discardableResult
    public func removeFirst() -> Element? {
        return _storage._removeFirst()?.storage
    }
    
    @discardableResult
    public func removeLast() -> Element? {
        return _storage._removeLast()?.storage
    }
    
    @discardableResult
    public func remove(at index: Int) -> Element? {
        return _storage._remove(index)?.storage
    }
    
    public func insert(_ element: Element, at index: Int) {
        _storage._insert(.init(storage: element, next: nil, prior: nil), at: index)
    }
    
    public func insert<S: Sequence>(_ elements: S, at index: Int) where S.Element == Element {
        guard let target = _storage._find(index) else {
            append(contentsof: elements)
            return
        }
        let newLinked: DataStruct.DoubleLinkedList<Element> = .init(elements)
        let newStorage = newLinked._storage
        let p = target.prior
        p?.next = newStorage.front
        newStorage.front = p
        target.prior = newStorage.rear
        newStorage.rear?.next = target
    }
    
    public func update(_ element: Element, at index: Int) {
        guard let target = _storage._find(index) else {
            append(element)
            return
        }
        target.storage = element
    }
    
    public func removeAll() {
        _storage._removeAll()
    }
    
    public func reversed() {
        _storage._reversed = !_storage._reversed
    }
    
    public subscript(position: Int) -> Element? {
        set {
            guard let element = newValue else { return }
            guard let target = _storage._find(position) else {
                append(element)
                return
            }
            target.storage = element
        }
        get {
            return _storage._find(position)?.storage
        }
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

    public var count: Int { _storage.count }
    public var isEmpty: Bool { _storage.isEmpty }

    public struct Iterator: IteratorProtocol {

        internal var _front: _Storage._DoubleStorageNode<Element>?
        internal var _rear: _Storage._DoubleStorageNode<Element>?
        internal var _next: _Storage._DoubleStorageNode<Element>?
        internal var _reversed: Bool

        internal init(_storage: _Storage) {
            self._front = _storage.front
            self._rear = _storage.rear
            self._next = _storage._reversed ? _storage.rear : _storage.front
            self._reversed = _storage._reversed
        }

        mutating public func next() -> Element? {
            let storage = _next?.storage
            _next = _reversed ? _next?.prior : _next?.next
            return storage
        }
    }

    public func makeIterator() -> Iterator {
        return .init(_storage: _storage)
    }
}

extension DataStruct.DoubleLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String { map { "\($0)" }.joined(separator: "<->") }
    
}
