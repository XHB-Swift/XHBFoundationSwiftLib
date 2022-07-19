//
//  URLSession+Reactive.swift
//  
//
//  Created by 谢鸿标 on 2022/7/12.
//

import Foundation

extension URLSession {
    
    public struct DataTaskOservation: Observable {
        
        public typealias Output = (data: Data, response: URLResponse)
        public typealias Failure = URLError
        
        public let request: URLRequest
        public let session: URLSession
        
        private let _signalConduit: _DataTaskSignalConduit
        
        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
            self._signalConduit = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._signalConduit.attach(observer, to: session, request: request)
        }
    }
}

extension URLSession.DataTaskOservation {
    
    fileprivate final class _DataTaskSignalConduit: SignalConduit {
        
        private struct DataTaskObserver {
            
            var dataTask: URLSessionDataTask
            var observer: AnyObserver<Output, Failure>
        }
        
        private var observers: Dictionary<UUID, DataTaskObserver>
        
        override init() {
            observers = .init()
        }
        
        override func send() {
            guard requirement > .none else { return }
            observers.forEach { $1.dataTask.resume() }
        }
        
        override func dispose() {
            observers.forEach { $1.dataTask.cancel() }
            observers.removeAll()
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
        
        private func receive(_ value: Output, _ id: UUID) {
            guard let dataObserver = observers[id] else { return }
            dataObserver.observer.receive(value)
            dataObserver.observer.receive(.finished)
        }
        
        private func receive(_ failure: Failure, _ id: UUID) {
            guard let dataObserver = observers[id] else { return }
            dataObserver.observer.receive(.failure(failure))
        }
        
        func attach<Ob>(_ observer: Ob, to session: URLSession, request: URLRequest) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            let id: UUID = .init()
            let anyObserver: AnyObserver<Output, Failure> = .init(observer)
            let dataTask = session.dataTask(with: request,
                                             completionHandler: { [weak self] data, response, error in
                if let data = data,
                   let response = response {
                    self?.receive((data, response), id)
                } else if let error = error as? URLError {
                    self?.receive(error, id)
                }
            })
            observers[id] = .init(dataTask: dataTask, observer: anyObserver)
            anyObserver.receive(self)
        }
    }
}


extension URLSession {
    
    public func dataTaskObservation(for urlString: String) -> URLSession.DataTaskOservation? {
        guard let url = URL(string: urlString) else { return nil }
        return dataTaskObservation(for: url)
    }
    
    public func dataTaskObservation(for url: URL) -> URLSession.DataTaskOservation {
        return .init(request: .init(url: url), session: self)
    }
    
    public func dataTaskObservation(for request: URLRequest) -> URLSession.DataTaskOservation {
        return .init(request: request, session: self)
    }
}
