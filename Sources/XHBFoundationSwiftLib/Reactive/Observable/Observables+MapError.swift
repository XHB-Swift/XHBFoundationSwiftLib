//
//  Observables+MapError.swift
//  
//
//  Created by xiehongbiao on 2022/7/14.
//

import Foundation


extension Observables {
    
    public struct MapError<Source: Observable, Failure: Error>: Observable {
        
        public typealias Output = Source.Output
        
        public let source: Source
        public let transform: (Source.Failure) -> Failure
        private let _signalConduit: _MapErrorSignalConduit
        
        public init(source: Source, transform: @escaping (Source.Failure) -> Failure) {
            self.source = source
            self.transform = transform
            self._signalConduit = .init(transform)
        }
        
        public init(source: Source, _ map: @escaping (Source.Failure) -> Failure) {
            self.source = source
            self.transform = map
            self._signalConduit = .init(map)
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Source.Output == Ob.Input {
            self._signalConduit.attach(observer, to: source)
        }
    }
}

extension Observables.MapError {
    
    fileprivate final class _MapErrorSignalConduit: OneToOneSignalConduit<Source.Output, Failure, Source.Output, Source.Failure> {
        
        let transform: (Source.Failure) -> Failure
        
        init(_ transform: @escaping (Source.Failure) -> Failure) {
            self.transform = transform
        }
        
        override func receive(value: Source.Output) {
            anyObserver?.receive(value)
        }
        
        override func receive(failure: Source.Failure) {
            let newError = transform(failure)
            anyObserver?.receive(.failure(newError))
        }
        
        override func receiveCompletion() {
            anyObserver?.receive(.finished)
        }
    }
}
