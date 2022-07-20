//
//  _SingleLinkedListStorage.swift
//  
//
//  Created by 谢鸿标 on 2022/7/20.
//

import Foundation

internal final class _SingleLinkedListStorage<Element>: _LinkedListStorage<Element> {
    
    internal var front: _SingleNode<Element>?
    internal var rear: _SingleNode<Element>?
    internal override var loop: Bool {
        didSet {
            updateLoop()
        }
    }
    
    private func updateLoop() {
        if loop {
            rear?.next = front
        } else {
            rear?.next = nil
        }
    }
    
    internal override init() {
        super.init()
    }
    
    internal override init<S: Sequence>(_ s: S) where S.Element == Element {
        super.init(s)
        var iterator = s.makeIterator()
        while let element = iterator.next() {
            let node = _SingleNode(storage: element, next: nil)
            count += 1
            if count == 1 {
                front = node
            } else {
                rear?.next = node
            }
            rear = node
        }
    }
    
    internal override func _find(_ index: Int) -> _SingleNode<Element>? {
        if !(0..<count).contains(index) { return nil }
        if index == 0 { return front }
        if index == count - 1 { return rear }
        var node: _SingleNode<Element>?
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
    
    internal func _append(_ node: _SingleNode<Element>) {
        if isEmpty {
            front = node
        }
        rear?.next = node
        rear = node
        count += 1
        updateLoop()
    }
    
    internal func _insert(_ node: _SingleNode<Element>, at index: Int) {
        guard let target = _find(index) else {
            _append(node)
            return
        }
        let n = target.next
        target.next = node
        node.next = n
        count += 1
        if n == nil {
            rear = node
            updateLoop()
        }
    }
    
    internal override func _removeFirst() -> _SingleNode<Element>? {
        if isEmpty { return nil }
        defer {
            count -= 1
            front = front?.next
        }
        return front
    }
    
    internal override func _removeLast() -> _SingleNode<Element>? {
        if isEmpty { return nil }
        defer {
            rear = _find(count - 2)
            count -= 1
            updateLoop()
        }
        return rear
    }
    
    internal override func _remove(_ index: Int) -> _SingleNode<Element>? {
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
    
    internal override func _removeAll() {
        front = nil
        count = 0
    }
}

extension _SingleLinkedListStorage {
    
    internal final class _SingleNode<Element>: _LinkedListStorage<Element>._Node<Element> {
        
        internal var next: _SingleNode?
        
        internal init(storage: Element, next: _SingleNode?) {
            self.next = next
            super.init(storage: storage)
        }
    }
}
