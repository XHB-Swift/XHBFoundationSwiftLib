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
            self._signalConduit = .init(source: source, decoder: decoder)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer: observer)
        }
    }
}

extension Observables.Decode {
    
    fileprivate final class _DecodeSignalConduit: AutoCommonSignalConduit<Source.Output, Source.Failure> {
        
        var anyDecoder: AnyDataDecoder<Source.Output>
        private var newObservers: Dictionary<UUID, AnyObserver<Output, Failure>>
        
        init(source: Source, decoder: Decoder) {
            self.anyDecoder = .init(decoder)
            self.newObservers = .init()
            super.init(source: source)
        }
        
        override func receiveSignal(_ signal: Signal, _ id: UUID) {
            newObservers[id]?.receive(self)
        }
        
        override func receiveValue(_ value: Source.Output, _ id: UUID) {
            do {
                let result = try anyDecoder.decode(Output.self, from: value)
                newObservers[id]?.receive(result)
            } catch {
                cancel()
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
            fatalError("Should use `attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer`")
        }
        
        func attach<O>(observer: O) where Output == O.Input, Failure == O.Failure, O : Observer {
            let id = observer.identifier
            newObservers[id] = .init(observer)
            anySource?.subscribe(makeBridger(id))
        }
    }
}

extension Observable {
    
    public func decode<Item, Coder>(type: Item.Type, decoder: Coder)
    -> Observables.Decode<Self, Item, Coder> where Item : Decodable, Coder : DataDecoder, Self.Output == Coder.Input {
        return .init(source: self, decoder: decoder)
    }
}
