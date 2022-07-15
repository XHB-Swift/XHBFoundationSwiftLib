//
//  Observables+Decode.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct Decode<Source, Output, Decoder>: Observable
    where Source: Observable, Output: Decodable, Decoder: DataDecoder, Source.Output == Decoder.Input {
        
        public typealias Failure = Error
        
        public let source: Source
        private let _signalConduit: _DecodeSignalConduit
        
        public init(source: Source, decoder: Decoder) {
            self.source = source
            self._signalConduit = .init(decoder: decoder)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.Decode {
    
    fileprivate final class _DecodeSignalConduit: OneToOneSignalConduit<Output, Failure, Source.Output, Source.Failure> {
        
        var anyDecoder: AnyDataDecoder<Source.Output>
        
        init(decoder: Decoder) {
            self.anyDecoder = .init(decoder)
        }
        
        override func receive(value: Source.Output) {
            do {
                let result = try anyDecoder.decode(Output.self, from: value)
                anyObserver?.receive(result)
            } catch {
                disposeObservable()
                anyObserver?.receive(.failure(error))
            }
        }
        
        override func receive(failure: Source.Failure) {
            disposeObservable()
            anyObserver?.receive(.failure(failure))
        }
        
        override func receiveCompletion() {
            disposeObservable()
            anyObserver?.receive(.finished)
        }
    }
}

extension Observable {
    
    public func decode<Item, Coder>(type: Item.Type, decoder: Coder)
    -> Observables.Decode<Self, Item, Coder> where Item : Decodable, Coder : DataDecoder, Self.Output == Coder.Input {
        return .init(source: self, decoder: decoder)
    }
}
