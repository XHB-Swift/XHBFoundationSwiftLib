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

internal final class DoubleSingleLinkedListNode<Element> {
    
    internal var prior: DoubleSingleLinkedListNode?
    internal var next: DoubleSingleLinkedListNode?
    internal var storage: Element
    
    internal init(storage: Element, next: DoubleSingleLinkedListNode<Element>?, prior: DoubleSingleLinkedListNode<Element>?) {
        self.prior = prior
        self.next = next
        self.storage = storage
    }
}
