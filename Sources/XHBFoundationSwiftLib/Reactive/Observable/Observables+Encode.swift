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
            self._signalConduit = .init(source: source, encoder: encoder)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Encoder.Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Encode {
    
    fileprivate final class _EncodeSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        var anyEncoder: AnyDataEncoder<Output>
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        
        init(source: Source, encoder: Encoder) {
            self.anyEncoder = .init(encoder)
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(signal)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            do {
                let result = try anyEncoder.encode(value)
                newObservers[id]?.receive(result)
            } catch {
                newObservers[id]?.receive(.failure(error))
            }
        }
        
        override func receiveFailure(_ failure: Source.Failure, _ id: UUID) {
            cancel()
            newObservers[id]?.receive(.failure(failure))
        }
        
        override func receiveCompletion(_ id: UUID) {
            newObservers[id]?.receive(.finished)
        }
        
        override func attach<O>(observer: O) where Source.Output == O.Input, Source.Failure == O.Failure, O : Observer {
            fatalError("Should use `attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Encoder.Output == Ob.Input`")
        }
        
        func attach<Ob>(observer: Ob) where Ob : Observer, Failure == Ob.Failure, Encoder.Output == Ob.Input {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
        
    }
    
}

extension Observable {
    
    public func encode<Coder>(encoder: Coder) -> Observables.Encode<Self, Coder> where Coder : DataEncoder {
        return .init(source: self, encoder: encoder)
    }
    
}
