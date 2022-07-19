//
//  LinkedListNode.swift
//  
//
//  Created by xiehongbiao on 2022/7/19.
//

import Foundation

internal class LinkedListNode<Element> {
    
    internal var next: LinkedListNode?
    internal var storage: Element
    
    internal init(storage: Element, next: LinkedListNode?) {
        self.storage = storage
        self.next = next
    }
}
