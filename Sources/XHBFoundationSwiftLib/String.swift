//
//  String.swift
//  
//
//  Created by xiehongbiao on 2022/6/24.
//

import Foundation
import CryptoKit
import CommonCrypto

extension String {
    public var hexStringToInt: Int {
        return Int(self, radix: 16) ?? 0
    }
    
    public subscript(i: Int) -> Self? {
        if i >= count {
            return nil
        }
        if i == 0 {
            return String(self[startIndex])
        }
        if i == count - 1 {
            return String(self[endIndex])
        }
        
        let targetIndex = index(startIndex, offsetBy: i)
        return String(self[targetIndex])
    }
    
    public subscript(r: Range<Int>) -> Self? {
        if r.lowerBound < 0 {
            return nil
        }
        if r.lowerBound >= count {
            return nil
        }
        if r.upperBound > count {
            return nil
        }
        let index0 = index(startIndex, offsetBy: r.lowerBound)
        let index1 = index(startIndex, offsetBy: r.upperBound)
        return String(self[index0..<index1])
    }
    
    public subscript(r: NSRange) -> Self? {
        guard let rr = Range(r) else { return nil }
        return self[rr]
    }
    
    public var objectClassName: String? {
        
        guard let space = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return nil }
        return "\(space.replacingOccurrences(of: "-", with: "_")).\(self)"
    }
    
    public var md5String: Self {
        if isEmpty { return self }
        if #available(iOS 13.0, macOS 10.15, *) {
            guard let d = self.data(using: .utf8) else { return "" }
            return Insecure.MD5.hash(data: d).map {
                String(format: "%02hhx", $0)
            }.joined()
        }else {
            let data = Data(utf8)
            let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
                var array = Array<UInt8>(repeating: 0, count: Int(CC_MD5_BLOCK_BYTES))
                CC_MD5(bytes.baseAddress, CC_LONG(data.count), &array)
                return array
            }
            return hash.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    public  func appending(path: Self) -> Self {
        let pathHasPrefixSlash = path.hasPrefix("/")
        let currentHasSuffixSlash = self.hasSuffix("/")
        if (pathHasPrefixSlash && !currentHasSuffixSlash) ||
            (!pathHasPrefixSlash && currentHasSuffixSlash){
            return appending(path)
        } else if pathHasPrefixSlash && currentHasSuffixSlash {
            guard let ss = self[count - 1] else { return appending(path) }
            return ss.appending(path)
        } else {
            return appending("/\(path)")
        }
    }
    
    public mutating func append(path: Self) {
        let pathHasPrefixSlash = path.hasPrefix("/")
        let currentHasSuffixSlash = self.hasSuffix("/")
        if (pathHasPrefixSlash && !currentHasSuffixSlash) ||
            (!pathHasPrefixSlash && currentHasSuffixSlash){
            self.append(path)
        } else if pathHasPrefixSlash && currentHasSuffixSlash {
            guard let ss = self[count - 1] else { return }
            self = ss.appending(path)
        } else if !pathHasPrefixSlash && !currentHasSuffixSlash {
            self.append("/\(path)")
        }
    }
    
    public var urlEncoded: Self {
        let encodedUrlString = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodedUrlString ?? ""
    }
    
    public var urlDecoded: Self {
        return removingPercentEncoding ?? ""
    }
}
