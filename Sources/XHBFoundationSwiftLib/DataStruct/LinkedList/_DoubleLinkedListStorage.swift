//
//  _DoubleLinkedListStorage.swift
//  
//
//  Created by 谢鸿标 on 2022/7/20.
//

import Foundation

internal final class _DoubleLinkedListStorage<Element>: _LinkedListStorage<Element> {
    
    internal var front: _DoubleStorageNode<Element>?
    internal var rear: _DoubleStorageNode<Element>?
    internal var _reversed = false
    
    internal override var loop: Bool {
        didSet {
            if loop {
                front?.prior = rear
                rear?.next = front
            } else {
                front?.prior = nil
                rear?.next = nil
            }
        }
    }
    
    internal override init() { super.init() }
    
    internal override init<S: Sequence>(_ s: S) where S.Element == Element {
        super.init(s)
        var iterator = s.makeIterator()
        var prior: _DoubleStorageNode<Element>?
        while let next = iterator.next() {
            count += 1
            let node: _DoubleStorageNode<Element> = .init(storage: next, next: nil, prior: nil)
            if count == 1 {
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
    
    internal override func _find(_ index: Int) -> _DoubleStorageNode<Element>? {
        if !(0..<count).contains(index) { return nil }
        if index == 0 { return front }
        if index == count - 1 { return rear }
        var node: _DoubleStorageNode<Element>?
        var i = 1
        while let next = _reversed ? rear?.prior : front?.next,
              i < count - 2 {
            if i == index {
                node = next
                break
            }
            i += 1
        }
        return node
    }
    
    internal func _append(_ node: _DoubleStorageNode<Element>) {
        if isEmpty {
            front = node
        }
        rear?.next = node
        node.prior = rear
        rear = node
        count += 1
    }
    
    internal func _insert(_ node: _DoubleStorageNode<Element>, at index: Int) {
        guard let target = _find(index) else {
            _append(node)
            return
        }
        let p = target.prior
        p?.next = node
        node.prior = p
        target.prior = node
        node.next = target
        count += 1
    }
    
    internal override func _removeFirst() -> _DoubleStorageNode<Element>? {
        if isEmpty { return nil }
        defer {
            count -= 1
            if _reversed {
                rear = rear?.prior
            } else {
                front = front?.next
            }
        }
        return front
    }
    
    internal override func _removeLast() -> _DoubleStorageNode<Element>? {
        if isEmpty { return nil }
        defer {
            count -= 1
            if _reversed {
                front = front?.next
            } else {
                rear = rear?.prior
            }
        }
        return rear
    }
    
    internal override func _remove(_ index: Int) -> _DoubleStorageNode<Element>? {
        if isEmpty { return nil }
        if index == count - 1 { return _removeLast() }
        if index == 0 { return _removeFirst() }
        let target = _find(index)
        let p = target?.prior
        let n = target?.next
        p?.next = n
        n?.prior = p
        count -= 1
        return target
    }
    
    internal override func _removeAll() {
        front = nil
        rear = nil
        count = 0
    }
}

extension _DoubleLinkedListStorage {
    
    internal class _DoubleStorageNode<Element>: _LinkedListStorage<Element>._Node<Element> {
        
        internal weak var prior: _DoubleStorageNode?
        internal var next: _DoubleStorageNode?
        
        internal init(storage: Element, next: _DoubleStorageNode?, prior: _DoubleStorageNode?) {
            self.prior = prior
            self.next = next
            super.init(storage: storage)
        }
    }
}
