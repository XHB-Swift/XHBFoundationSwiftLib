//
//  Signal.swift
//  
//
//  Created by xiehongbiao on 2022/7/11.
//

import Foundation

public protocol Signal: Cancellable {
    
    var identifier: UUID { get }
    func request(_ requirement: Requirement)
}

public enum Signals {}

extension Signals {
    
    public static var empty: Signal {
        return PassSignalConduit<Never, Never>()
    }
}

public struct Requirement {
    
    public var number: Int?
}

extension Requirement {
    
    public static let none: Requirement = .init(number: 0)
    public static let unlimited: Requirement = .init(number: nil)
    public static func max(_ number: Int) -> Requirement { return .init(number: number) }
}

extension Requirement: Equatable {
    
    public static func == (lhs: Requirement, rhs: Requirement) -> Bool {
        return lhs.number == rhs.number
    }
    
    public static func == (lhs: Requirement, rhs: Int) -> Bool {
        guard let lhsNumber = lhs.number else { return false }
        return lhsNumber == rhs
    }
    
    public static func == (lhs: Int, rhs: Requirement) -> Bool {
        guard let rhsNumebr = rhs.number else { return false }
        return lhs == rhsNumebr
    }
}

extension Requirement: Comparable {
    
    public static func < (lhs: Requirement, rhs: Requirement) -> Bool {
        guard let lhsNumber = lhs.number else { return rhs != .unlimited }
        if let rhsNumber = rhs.number {
            return lhsNumber < rhsNumber
        } else {
            return true
        }
    }
    
    public static func < (lhs: Requirement, rhs: Int) -> Bool {
        guard let lhsNumber = lhs.number else { return false }
        return lhsNumber < rhs
    }
    
    public static func < (lhs: Int, rhs: Requirement) -> Bool {
        guard let rhsNumber = rhs.number else { return true }
        return lhs < rhsNumber
    }
    
    public static func <= (lhs: Requirement, rhs: Requirement) -> Bool {
        guard let lhsNumber = lhs.number else { return rhs == .unlimited }
        if let rhsNumber = rhs.number {
            return lhsNumber <= rhsNumber
        } else {
            return true
        }
    }
    
    public static func <= (lhs: Requirement, rhs: Int) -> Bool {
        guard let lhsNumber = lhs.number else { return false }
        return lhsNumber <= rhs
    }
    
    public static func <= (lhs: Int, rhs: Requirement) -> Bool {
        guard let rhsNumber = rhs.number else { return true }
        return lhs <= rhsNumber
    }
    
    public static func >= (lhs: Requirement, rhs: Requirement) -> Bool {
        guard let lhsNumber = lhs.number else { return true }
        if let rhsNumber = rhs.number {
            return lhsNumber >= rhsNumber
        } else {
            return false
        }
    }
    
    public static func >= (lhs: Requirement, rhs: Int) -> Bool {
        guard let lhsNumber = lhs.number else { return true }
        return lhsNumber >= rhs
    }
    
    public static func >= (lhs: Int, rhs: Requirement) -> Bool {
        guard let rhsNumber = rhs.number else { return true }
        return lhs >= rhsNumber
    }
    
    public static func > (lhs: Requirement, rhs: Requirement) -> Bool {
        guard let lhsNumber = lhs.number else { return rhs != .unlimited }
        if let rhsNumber = rhs.number {
            return lhsNumber > rhsNumber
        } else {
            return false
        }
    }
    
    public static func > (lhs: Requirement, rhs: Int) -> Bool {
        guard let lhsNumber = lhs.number else { return true }
        return lhsNumber > rhs
    }
    
    public static func > (lhs: Int, rhs: Requirement) -> Bool {
        guard let rhsNumber = rhs.number else { return false }
        return lhs > rhsNumber
    }
}

extension Requirement: Hashable {
    
    public var hashValue: Int {
        return self.number ?? 0
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
}

extension Requirement {
    
    public static func + (lhs: Requirement, rhs: Requirement) -> Requirement {
        guard let lhsNumber = lhs.number else { return .unlimited }
        guard let rhsNumber = rhs.number else { return .unlimited }
        let result = lhsNumber + rhsNumber
        return .max(result < 0 ? 0 : result)
    }
    
    public static func += (lhs: inout Requirement, rhs: Requirement) {
        guard let lhsNumber = lhs.number else { return }
        guard let rhsNumber = rhs.number else {
            lhs = .unlimited
            return
        }
        let result = lhsNumber + rhsNumber
        lhs = .max(result < 0 ? 0 : result)
    }
    
    public static func + (lhs: Requirement, rhs: Int) -> Requirement {
        guard let lhsNumber = lhs.number else { return .unlimited }
        let result = lhsNumber + rhs
        return .max(result < 0 ? 0 : result)
    }
    
    public static func += (lhs: inout Requirement, rhs: Int) {
        guard let lhsNumber = lhs.number else { return }
        let result = lhsNumber + rhs
        lhs = .max(result < 0 ? 0 : result)
    }
    
    public static func - (lhs: Requirement, rhs: Requirement) -> Requirement {
        guard let lhsNumber = lhs.number else { return .unlimited }
        guard let rhsNumber = rhs.number else { return .unlimited }
        let result = lhsNumber - rhsNumber
        return .max(result < 0 ? 0 : result)
    }
    
    public static func -= (lhs: inout Requirement, rhs: Requirement) {
        guard let lhsNumber = lhs.number else { return }
        guard let rhsNumber = rhs.number else {
            lhs = .none
            return
        }
        let result = lhsNumber - rhsNumber
        lhs = .max(result < 0 ? 0 : result)
    }
    
    public static func - (lhs: Requirement, rhs: Int) -> Requirement {
        guard let lhsNumber = lhs.number else { return .unlimited }
        let result = lhsNumber - rhs
        return .max(result < 0 ? 0 : result)
    }
    
    public static func -= (lhs: inout Requirement, rhs: Int) {
        guard let lhsNumber = lhs.number else { return }
        let result = lhsNumber - rhs
        lhs = .max(result < 0 ? 0 : result)
    }
    
    public static func * (lhs: Requirement, rhs: Int) -> Requirement {
        guard let lhsNumber = lhs.number else { return .unlimited }
        let result = lhsNumber * rhs
        return .max(result < 0 ? 0 : result)
    }
    
    public static func *= (lhs: inout Requirement, rhs: Int) {
        guard let lhsNumber = lhs.number else { return }
        let result = lhsNumber * rhs
        lhs = .max(result < 0 ? 0 : result)
    }
}

extension Requirement: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "Requirement(number: \(number.printedString))"
    }
}
