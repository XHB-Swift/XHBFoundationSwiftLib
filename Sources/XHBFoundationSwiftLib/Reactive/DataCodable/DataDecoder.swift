//
//  DataDecoder.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

public protocol DataDecoder {
    
    associatedtype Input
    
    func decode<T>(_ type: T.Type, from input: Self.Input) throws -> T where T : Decodable
}

final class AnyDataDecoder<Input>: DataDecoder {
    
    private var box: _AnyDataDecoderBoxBase<Input>
    
    init<D: DataDecoder>(_ dataDecoder: D) where D.Input == Input {
        self.box = _AnyDataDecoderBox(base: dataDecoder)
    }
    
    func decode<T>(_ type: T.Type, from input: Input) throws -> T where T : Decodable {
        return try box.decode(type, from: input)
    }
}

fileprivate class _AnyDataDecoderBoxBase<Input>: DataDecoder {
    typealias Input = Input
    func decode<T>(_ type: T.Type, from input: Input) throws -> T where T : Decodable {
        fatalError("Should use `_AnyDataDecoderBox<Base: DataDecoder>`")
    }
}

fileprivate final class _AnyDataDecoderBox<Base: DataDecoder>: _AnyDataDecoderBoxBase<Base.Input> {
    
    var base: Base
    init(base: Base) { self.base = base }
    
    override func decode<T>(_ type: T.Type, from input: Base.Input) throws -> T where T : Decodable {
        return try base.decode(type, from: input)
    }
}
