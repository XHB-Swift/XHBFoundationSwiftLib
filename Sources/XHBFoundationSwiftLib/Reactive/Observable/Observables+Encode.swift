//
//  Observables+Encode.swift
//  
//
//  Created by 谢鸿标 on 2022/7/14.
//

import Foundation

extension Observables {
    
    public struct Encode<Source: Observable, Encoder: DataEncoder>: Observable where Source.Output: Encodable {
        
        public typealias Output = Encoder.Output
        public typealias Failure = Error
        
        public let source: Source
        private let _signalConduit: _EncodeSignalConduit
        
        public init(source: Source, encoder: Encoder) {
            self.source = source
            self._signalConduit = .init(encoder: encoder)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Encoder.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.Encode {
    
    fileprivate final class _EncodeSignalConduit: OneToOneSignalConduit<Output, Failure, Source.Output, Source.Failure> {
        
        var anyEncoder: AnyDataEncoder<Output>
        
        init(encoder: Encoder) {
            self.anyEncoder = .init(encoder)
        }
        
        override func receive(value: Source.Output) {
            do {
                let result = try anyEncoder.encode(value)
                anyObserver?.receive(result)
            } catch {
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
    
    public func encode<Coder>(encoder: Coder) -> Observables.Encode<Self, Coder> where Coder : DataEncoder {
        return .init(source: self, encoder: encoder)
    }
    
}
