//
//  Observable.swift
//  
//
//  Created by xiehongbiao on 2022/7/4.
//

import Foundation

public protocol Observable {
    
    associatedtype Output
    associatedtype Failure: Error
    
    func subscribe<Ob: Observer>(_ observer: Ob) where Output == Ob.Input, Failure == Ob.Failure
}
