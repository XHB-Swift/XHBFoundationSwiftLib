//
//  Collection.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation

extension Sequence {
    
    public func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }
}

extension Collection {
    
    public func sorted<Value: Comparable>(on property: KeyPath<Element, Value>,
                                        by areIncreasingOrder: (Value, Value)->Bool) -> [Element] {
        return sorted { value1, value2 in
            areIncreasingOrder(value1[keyPath: property], value2[keyPath: property])
        }
    }
    
    public subscript(safe index: Self.Index) -> Iterator.Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : nil
    }
    
    public var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension MutableCollection where Self: RandomAccessCollection {
    
    public mutating func sort<Value: Comparable>(on property: KeyPath<Element, Value>, by order: (Value, Value) throws -> Bool) rethrows {
        
        try sort { try order($0[keyPath: property], $1[keyPath: property]) }
    }
    
}

extension Dictionary where Key == String {
    
    public func value(for keyPath: String, seperator: String = ".") -> Value? {
        
        let keyArray = keyPath.components(separatedBy: seperator)
        
        var arrayIterator = keyArray.makeIterator()
        var currentKey = arrayIterator.next()
        var nextDict: Self? = self
        var targetValue: Value? = nil
        while currentKey != nil {
            
            if let k = currentKey {
                targetValue = nextDict?[k]
                if targetValue is Self {
                    nextDict = targetValue as? Self
                }
            }
            currentKey = arrayIterator.next()
        }
        
        return targetValue
    }
    
    subscript(keyPath: String, seperator: String = ".") -> Value? {
        
        get { value(for: keyPath, seperator: seperator) }
    }
}

extension Dictionary {
    
    public mutating func filter(with keys: Array<Key>, excepted: Bool = false) {
        guard !keys.isEmpty else { return }
        let keysSet = Set(keys)
        self = filter { keysSet.contains($0.key) != excepted }
    }
    
    public mutating func concat(dictionary: Self, keysMapping: Dictionary<Key,Key>) {
        
        if keysMapping.isEmpty {
            
            _ = dictionary.map { self[$0] = $1 }
            
        } else {
            
            _ = keysMapping.map { self[$0] = dictionary[$1] }
        }
    }
    
}

