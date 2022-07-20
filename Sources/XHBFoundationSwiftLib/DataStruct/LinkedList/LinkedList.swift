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
    var first: Element? { get }
    var last: Element? { get }
    
    subscript(_ index: Int) -> Element? { get set }
    
    func append(_ element: Element)
    
    func append<S: Sequence>(contentsof s: S) where S.Element == Element
    
    func insert(_ element: Element, at index: Int)
    
    @discardableResult
    func removeFirst() -> Element?
    
    @discardableResult
    func removeLast() -> Element?
    
    @discardableResult
    func remove(at index: Int) -> Element?
    
    func removeAll()
}

internal class _LinkedListStorage<Element> {
    
    internal var loop = false
    internal var count: Int = 0
    internal var isEmpty: Bool { count == 0 }
    
    internal init() {}
    
    internal init<S: Sequence>(_ s: S) where S.Element == Element {}
    
    internal func _find(_ index: Int) -> Node? {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _append(_ node: Node) {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _insert(_ node: Node, at index: Int) {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _removeFirst() -> Node? {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _removeLast() -> Node? {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _remove(_ index: Int) -> Node? {
        fatalError("Please use subsclass and implement this method")
    }
    
    internal func _removeAll() {
        fatalError("Please use subsclass and implement this method")
    }
}

extension _LinkedListStorage {
    
    internal typealias Node = _Node<Element>
    
    internal class _Node<Element> {
        
        internal var storage: Element
        
        internal init(storage: Element) {
            self.storage = storage
        }
    }
}
