//
//  SingleLinkedListNode.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

internal final class SingleLinkedListNode<Element> {
    
    internal var next: SingleLinkedListNode?
    internal var storage: Element
    
    internal init(storage: Element, next: SingleLinkedListNode?) {
        self.storage = storage
        self.next = next
    }
}

internal final class DoubleLinkedListNode<Element> {
    
    internal weak var prior: DoubleLinkedListNode?
    internal var next: DoubleLinkedListNode?
    internal var storage: Element
    
    internal init(storage: Element, next: DoubleLinkedListNode<Element>?, prior: DoubleLinkedListNode<Element>?) {
        self.prior = prior
        self.next = next
        self.storage = storage
    }
    
    deinit {
        #if DEBUG
        print("Released = \(self)")
        #endif
    }
}
