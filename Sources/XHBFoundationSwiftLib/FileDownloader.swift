//
//  FileDownloader.swift
//  
//
//  Created by 谢鸿标 on 2022/6/25.
//

import Foundation

private let lock = DispatchSemaphore(value: 1)

public let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

public typealias FileDownloaderCompletion = (_ result: Result<URL, Error>) -> Void

extension NSObject {
    
    open class func fetchCachedFile(with url: String,
                                    format: String? = nil,
                                    dirName: String? = nil,
                                    documentDirPath: String? = cacheDirectory,
                                    completion: FileDownloaderCompletion? = nil) {
        let mainBlock = { (_ result: Result<URL, Error>) in
            if Thread.isMainThread {
                completion?(result)
            } else {
                DispatchQueue.main.async {
                    completion?(result)
                }
            }
        }
        DispatchQueue.global().async {
            guard let cacheDirPath = documentDirPath else {
                mainBlock(.failure(CommonError(code: -100, reason: "找不到文件夹")))
                return
            }
            var cachedFilePath = cacheDirPath
            if let dirName = dirName {
                cachedFilePath = cacheDirPath.appending(path: dirName)
            }
            let fileMgr = FileManager.default
            if !fileMgr.fileExists(atPath: cachedFilePath) {
                do {
                    try fileMgr.createDirectory(atPath: cachedFilePath, withIntermediateDirectories: true)
                } catch {
                    mainBlock(.failure(error))
                    return
                }
            }
            guard let remoteUrl = URL(string: url) else {
                mainBlock(.failure(CommonError(code: 10, reason: "Invildate url: \(url)")))
                return
            }
            var fileName = remoteUrl.absoluteString.md5String
            if let format = format {
                fileName.append(".\(format)")
            }
            cachedFilePath.append(path: fileName)
            let localFileUrl = URL(fileURLWithPath: cachedFilePath)
            if fileMgr.fileExists(atPath: cachedFilePath) {
                mainBlock(.success(localFileUrl))
                return
            }
            self .downloadFile(with: remoteUrl, cachedFileUrl: localFileUrl, completion: mainBlock)
        }
    }
    
    @available(macOS 10.15, iOS 13, *)
    open class func asyncFetchCachedFile(with url: String,
                                         format: String? = nil,
                                         dirName: String? = nil,
                                         documentDirPath: String? = cacheDirectory) async throws -> URL {
        return try await withTaskCancellationHandler(operation: {
            return try await withUnsafeThrowingContinuation({ continuation in
                fetchCachedFile(with: url, format: format, dirName: dirName, documentDirPath: documentDirPath) { result in
                    switch result {
                    case .success(let cachedLocalUrl):
                        continuation.resume(returning: cachedLocalUrl)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            })
        }, onCancel: {
            
        })
    }
    
    private class func downloadFile(with url: URL, cachedFileUrl: URL, completion: FileDownloaderCompletion? = nil) {
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            
            if let happenedError = error {
                completion?(.failure(happenedError))
            } else {
                lock.wait()
                let fileMgr = FileManager.default
                guard let location = location,
                      let httpResponse = response as? HTTPURLResponse else {
                    lock.signal()
                    completion?(.failure(CommonError(code: -1024, reason: "此处需要调试")))
                    return
                }
                let statusCode = httpResponse.statusCode
                if statusCode != 200 {
                    lock.signal()
                    completion?(.failure(CommonError(code: statusCode, reason: "Invalidate HTTP Code")))
                    return
                }
                do {
                    
                    if fileMgr.fileExists(atPath: cachedFileUrl.relativePath) {
                        try fileMgr.removeItem(at: cachedFileUrl)
                    }
                    try fileMgr.moveItem(at: location, to: cachedFileUrl)
                    lock.signal()
                    completion?(.success(cachedFileUrl))
                    
                } catch {
                    
                    lock.signal()
                    completion?(.failure(error))
                }
            }
            
        }.resume()
    }
    
}
