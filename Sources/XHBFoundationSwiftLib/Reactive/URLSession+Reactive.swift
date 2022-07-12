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
        
        private let _dataTaskManager: _DataTaskManager
        
        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
            self._dataTaskManager = .init()
        }
        
        public func subscribe<Ob>(_ observer: Ob) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self._dataTaskManager.attach(observer, to: session, request: request)
        }
    }
}

extension URLSession.DataTaskOservation {
    
    fileprivate final class _DataTaskManager: SignalConduit {
        
        private var observer: AnyObserver<Output, Failure>?
        private var dataTask: URLSessionDataTask?
        
        override func send() {
            guard requirement > .none else { return }
            dataTask?.resume()
        }
        
        override func dispose() {
            dataTask?.cancel()
            dataTask = nil
            observer = nil
        }
        
        deinit {
            #if DEBUG
            print("Released = \(self)")
            #endif
        }
        
        private func receive(_ value: Output) {
            self.observer?.receive(value)
        }
        
        private func receive(_ failure: Failure) {
            self.observer?.receive(.failure(failure))
        }
        
        func attach<Ob>(_ observer: Ob, to session: URLSession, request: URLRequest) where Ob : Observer, Failure == Ob.Failure, Output == Ob.Input {
            self.observer = .init(observer)
            self.dataTask = session.dataTask(with: request,
                                             completionHandler: { [weak self] data, response, error in
                if let data = data,
                   let response = response {
                    self?.receive((data, response))
                } else if let error = error as? URLError {
                    self?.receive(error)
                }
            })
            self.observer?.receive(self)
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
