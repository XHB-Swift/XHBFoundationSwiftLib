//
//  SelectorSignalConduit.swift
//  
//
//  Created by xiehongbiao on 2022/7/21.
//

import Foundation

class SelectorSignalConduit<Source, Output, Failure: Error>: Signal {
    
    let identifier: UUID = .init()
    
    private(set) var requirement: Requirement = .none
    private var observers: Dictionary<UUID, AnyObserver<Output, Failure>> = .init()
    
    var source: Source?
    let selector: Selector = #selector(selectorAction(_:))
    
    deinit { cancel() }
    
    init() {}
    
    init(source: Source?) {
        self.source = source
    }
    
    func cancel() {
        source = nil
        requirement = .none
        observers.removeAll()
    }
    
    func request(_ requirement: Requirement) {
        if self.requirement != requirement {
            self.requirement = requirement
        }
        if self.requirement == .none {
            return
        }
    }
    
    @objc func selectorAction(_ sender: Any) {
        guard let output = sender as? Output else { return }
        observers.forEach { (_,observer) in
            observer.receive(output)
        }
    }
    
    func attach<O: Observer>(observer: O) where O.Input == Output, O.Failure == Failure {
        observers[observer.identifier] = .init(observer)
        observer.receive(self)
    }
}
