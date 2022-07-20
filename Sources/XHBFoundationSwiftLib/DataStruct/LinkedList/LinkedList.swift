//
//  LinkedList.swift
//  
//
//  Created by xiehongbiao on 2022/7/20.
//

import Foundation

public protocol LinkedListModule {
    
    associatedtype Element
    
    var count: Int { get }
    var isEmpty: Bool { get }
    
    subscript(_ index: Int) -> Element? { get }
    func append(_ element: Element)
    func append<S: Sequence>(contentsof s: S) where S.Element == Element
    func insert(_ element: Element, at index: Int)
    func removeFirst() -> Element?
    func removeLast() -> Element?
    func remove(at index: Int) -> Element?
    func removeAll()
}

internal class _LinkedList<Element> {
    
    internal var front: _Node?
    internal var rear: _Node?
    internal var count: Int = 0
    internal var isEmpty: Bool { count == 0 }
    
    internal init() {}
    
    internal init<S: Sequence>(_ s: S) where S.Element == Element {
        var iterator = s.makeIterator()
        while let element = iterator.next() {
            let node = _Node(storage: element, next: nil)
            count += 1
            if count == 1 {
                front = node
            } else {
                rear?.next = node
            }
            rear = node
        }
    }
    
    internal func _find(_ index: Int) -> _Node? {
        if !(0..<count).contains(index) { return nil }
        if index == 0 { return front }
        if index == count - 1 { return rear }
        var node: _Node?
        var i = 1
        while let next = front?.next,
              i < count - 2 {
            if i == index {
                node = next
                break
            }
            i += 1
        }
        return node
    }
    
    internal func _append(_ node: _Node) {
        if isEmpty {
            front = node
        }
        rear?.next = node
        rear = node
        count += 1
    }
    
    internal func _insert(_ node: _Node, at index: Int) {
        guard let target = _find(index) else {
            _append(node)
            return
        }
        let n = target.next
        target.next = node
        node.next = n
        count += 1
    }
    
    internal func _removeFirst() -> _Node? {
        if isEmpty { return nil }
        defer {
            count -= 1
            front = front?.next
        }
        return front
    }
    
    internal func _removeLast() -> _Node? {
        if isEmpty { return nil }
        defer {
            rear = _find(count - 2)
            count -= 1
        }
        return rear
    }
    
    internal func _remove(_ index: Int) -> _Node? {
        if isEmpty { return nil }
        if index == count - 1 { return _removeLast() }
        if index == 0 { return _removeFirst() }
        let p = _find(index - 1)
        let target = p?.next
        let n = target?.next
        p?.next = n
        target?.next = nil
        count -= 1
        return target
    }
    
    internal func _removeAll() {
        front = nil
        count = 0
    }
}

extension _LinkedList {
    
    internal typealias _Node = _LinkedListNode<Element>
    
    internal class _LinkedListNode<Element> {
        
        internal var next: _Node?
        internal var storage: Element
        
        internal init(storage: Element, next: _Node?) {
            self.storage = storage
            self.next = next
        }
    }
}
