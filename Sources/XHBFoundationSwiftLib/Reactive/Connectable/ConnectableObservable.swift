//
//  ConnectableObservable.swift
//  
//
//  Created by xiehongbiao on 2022/7/15.
//

import Foundation

public protocol ConnectableObservable: Observable {
    
    func connect() -> Cancellable
}
