//
//  DataEncoder.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

public protocol DataEncoder {
    
    associatedtype Output
    
    func encode<T>(_ value: T) throws -> Self.Output where T : Encodable
}

final class AnyDataEncoder<Output>: DataEncoder {
    
    private var box: _AnyDataEncoderBoxBase<Output>
    
    init<D: DataEncoder>(_ dataEncoder: D) where D.Output == Output {
        self.box = _AnyDataEncoderBox(base: dataEncoder)
    }
    
    func encode<T>(_ value: T) throws -> Output where T : Encodable {
        return try box.encode(value)
    }
}

fileprivate class _AnyDataEncoderBoxBase<Output>: DataEncoder {
    typealias Output = Output
    func encode<T>(_ value: T) throws -> Output where T : Encodable {
        fatalError("Should use `_AnyDataEncoderBox<Base: DataEncoder>`")
    }
}

fileprivate final class _AnyDataEncoderBox<Base: DataEncoder>: _AnyDataEncoderBoxBase<Base.Output> {
    
    var base: Base
    init(base: Base) { self.base = base }
    
    override func encode<T>(_ value: T) throws -> Base.Output where T : Encodable {
        return try base.encode(value)
    }
}
