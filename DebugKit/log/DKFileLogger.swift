//
//  DKFileLogger.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/2.
//

import Foundation


extension Notification.Name {
    static let DKFLLogDidLog = Notification.Name("DKFileLoggerDidLog")
}

enum DKFileLoggerKey: String {
    case message
    case path
}

class DKFileLogger: NSObject, DKLogger {
    
    let defaultLogMaxFileSize      = 1024 * 1024;      // 1 MB
    
    var name: String = "fileLogger"
    
    var logFromatter: DKLogFormatter?
    
    let logFileManager: DKLogFileManager
    let queue: DispatchQueue
    var fromLaunchCreatedFile = false
    var _currentLogFileHandle: FileHandle?
    var _currentLogFileInfo: DKLogFileInfo?
    
    init(manager: DKLogFileManager, queue: DispatchQueue?) {
        self.queue = queue ?? DispatchQueue(label: "DKFileLogger")
        
        logFileManager = manager
        logFromatter = DKFileFormatter(dateFormatter: nil)
    }
    
    
    // MARK: DKLogger Protocol
    func log(message: DKLogMessage) {
        queue.async { [weak self] in
            guard let data = self?.data(logMessage: message), data.count > 0 else {
                return
            }
            
            self?.logData(data: data)
            
            if let filePath = self?._currentLogFileInfo?.filePath {
                NotificationCenter.default.post(name: .DKFLLogDidLog, object: nil,
                                                userInfo: [
                                                    DKFileLoggerKey.message: message,
                                                    DKFileLoggerKey.path: filePath
                                                ])
            }
        }
    }
    
    // MARK: Internal
    private func logData(data: Data) {
        do {
            let handle = currentLogFileHandle()
            if #available(iOS 13.4, *) {
                try handle.seekToEnd()
                handle.write(data)
            } else {
                handle.seekToEndOfFile()
                handle.write(data)
            }
        } catch {
            DebugKit.log("DKLog: \(error)")
        }
    }
    
    
    private func currentLogFileHandle() -> FileHandle {
        if let fileHandle = _currentLogFileHandle,
           let fileInfo = _currentLogFileInfo,
           canUseFile(fileInfo: fileInfo) {
            return fileHandle
        } else {
            let logFilePath = currentLogFileInfo().filePath
            let logFileHandle = try! FileHandle(forWritingTo: URL(fileURLWithPath: logFilePath))
            if #available(iOS 13.4, *) {
                do {
                    try logFileHandle.seekToEnd()
                } catch {
                    DebugKit.log("DKLog: \(error)")
                }
                
            } else {
                logFileHandle.seekToEndOfFile()
            }
            _currentLogFileHandle = logFileHandle
            return logFileHandle
        }
    }
    
    private func currentLogFileInfo() -> DKLogFileInfo {
        var newCurrentLogFile = _currentLogFileInfo
        
        if newCurrentLogFile == nil {
            newCurrentLogFile = logFileManager.sortedLogFileInfos.first
        }
        
        if let currentLogFile = newCurrentLogFile,
           canUseFile(fileInfo: currentLogFile) {
            return currentLogFile
        } else {
            let currentLogFilePath = try! logFileManager.createNewLogFile()
            let currentLogFile = DKLogFileInfo(filePath: currentLogFilePath!)
            _currentLogFileInfo = currentLogFile
            fromLaunchCreatedFile = true
            return currentLogFile
        }
    }
    
    private func data(logMessage: DKLogMessage) -> Data? {
        var message = logMessage.message
        var isFormatted = false
        
        if let fromatter = logFromatter {
            message = fromatter.format(message: logMessage)
            isFormatted = message != logMessage.message
        }
        
        let shouldFormat = !isFormatted
        if shouldFormat {
            message = "\(message)\n"
        }
        return message.data(using: .utf8)
    }
    
    private func canUseFile(fileInfo: DKLogFileInfo) -> Bool {
        if !fromLaunchCreatedFile {
            return false
        }
        
        if fileInfo.fileSize > defaultLogMaxFileSize {
            return false
        }
        
        return true
    }
}

class DKFileFormatter: DKLogFormatter {
    
    let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter?) {
        if let dateFormatter = dateFormatter {
            self.dateFormatter = dateFormatter
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
            self.dateFormatter = dateFormatter
        }
    }
    
    func format(message: DKLogMessage) -> String {
        let timeStr = dateFormatter.string(from: message.date)
        let messageStr = message.message.replacingOccurrences(of: "\n", with: "")
        
        let formatedMessage = DKLogMessage(message: messageStr,
                                           keyword: message.keyword,
                                           summary: message.summary,
                                           timestamp: timeStr,
                                           date: message.date)
        
        var formatedStr = ""
        if let data = try? JSONEncoder().encode(formatedMessage),
           let dataStr =  String(data: data, encoding: .utf8) {
            formatedStr = dataStr
        }
        formatedStr.append("\n")
        
        
        return formatedStr
    }
}

protocol DKLogFileManager {
    var maxinumNumberOfLogFiles: UInt { get set }
    var logFilesDiskQuota: UInt64 { get set }
    var logsDirectory: String { get }
    var unsortedLogFilePaths: [String] { get }
    var unsortedLogFileNames: [String] { get }
    var unsortedLogFileInfos: [DKLogFileInfo] { get }
    var sortedLogFilePaths: [String] { get }
    var sortedLogFileNames: [String] { get }
    var sortedLogFileInfos: [DKLogFileInfo] { get }
    
    func createNewLogFile() throws -> String?
    
//    func didArchiveLogFile(atPath: String, wasRolled: Bool) -> Void
}

class DKFileManagerDefault: DKLogFileManager {
    
    var maxinumNumberOfLogFiles: UInt = 20 // 5 Files
    var logFilesDiskQuota: UInt64 = 20 * 1024 * 1024 // 20 MB
    
    let fileDateFormatter: DateFormatter
    
    private(set) var logsDirectory: String
    
    convenience init() {
        self.init(logsDirectory: nil)
    }
    
    init(logsDirectory: String?) {
        
        fileDateFormatter = DateFormatter()
        fileDateFormatter.dateFormat = "yyyy-MM-dd--HH-mm-ss-SSS"
        
        if let logsDirectory = logsDirectory,
           logsDirectory.count > 0 {
            self.logsDirectory = logsDirectory
        } else {
            self.logsDirectory = Self.self.defaultLogsDirectory()
        }
        
        assert(self.logsDirectory.count > 0, "目录必须设置")
        
        do {
            try FileManager.default.createDirectory(atPath: self.logsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DebugKit.log("DKLog: \(error)")
        }
    }
    
    // MARK: Log Files
    static func defaultLogsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var logsDirectory = ""
        if let firstPath = paths.first {
            logsDirectory = NSString(string: firstPath).appendingPathComponent("Logs")
        }
        return logsDirectory
    }
    
    // /Users/wangyinghui/Library/Developer/CoreSimulator/Devices/63820BE1-1CFA-48F3-8588-93C17984AC0D/data/Containers/Data/Application/82A0E9DB-73D0-464A-84F4-B864B8499035/Library/Caches/Logs/com.didi.dokit.demo.test.a123 2021-09-02--00-12-30-820.log
    func isLogFile(fileName: String) -> Bool {
        let appName = DebugKit.appName()
        
        let hasProperPrefix = fileName.hasPrefix("\(appName) ")
        let hasProperSuffix = fileName.hasSuffix(".log")
        
        return hasProperPrefix && hasProperSuffix
    }
    
    var unsortedLogFilePaths: [String] {
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: logsDirectory) else {
            return []
        }
        
        return fileNames.filter {
            isLogFile(fileName: $0)
        } .map {
            NSString(string: logsDirectory).appendingPathComponent($0)
        }
    }
    
    var unsortedLogFileNames: [String] {
        unsortedLogFilePaths.map {
            NSString(string: $0).lastPathComponent
        }
    }
    
    var unsortedLogFileInfos: [DKLogFileInfo] {
        unsortedLogFilePaths.map {
            DKLogFileInfo(filePath: $0)
        }
    }
    
    var sortedLogFilePaths: [String] {
        sortedLogFileInfos.map { $0.filePath as String }
    }
    
    var sortedLogFileNames: [String] {
        sortedLogFileInfos.map { $0.fileName }
    }
    
    var sortedLogFileInfos: [DKLogFileInfo] {
        unsortedLogFileInfos.sorted { fileInfo1, fileInfo2 in
            var date1 = Date()
            var date2 = Date()
            
            let arrayComponet1 = fileInfo1.fileName.components(separatedBy: " ")
            if let last = arrayComponet1.last {
                let dateString = last.replacingOccurrences(of: ".log", with: "")
                date1 = fileDateFormatter.date(from: dateString) ?? fileInfo1.creationDate
            }
            
            let arrayComponet2 = fileInfo2.fileName.components(separatedBy: " ")
            if let last = arrayComponet2.last {
                let dateString = last.replacingOccurrences(of: ".log", with: "")
                date2 = fileDateFormatter.date(from: dateString) ?? fileInfo1.creationDate
            }
            
            return date2.compare(date1) == .orderedAscending
        }
    }
    
    // MARK: Creation
    func newLogFileName() -> String {
        let appName = DebugKit.appName()
        let fomattedDate = fileDateFormatter.string(from: Date())
        return "\(appName) \(fomattedDate).log"
    }
    
    
    func createNewLogFile() throws -> String? {
        
        let fileName = newLogFileName()
        let fileHeader = Data()
        
        let filePath = NSString(string: logsDirectory).appendingPathComponent(fileName)
        
        try fileHeader.write(to: URL(fileURLWithPath: filePath), options: .atomicWrite)
        
        deleteOldLogFiles()
        DebugKit.log("DKLog: createFile: \(filePath)")
        
        return filePath
    }
    
    // MARK: File Deleting
    func deleteOldLogFiles() {
        let sortedLogFileInfos = sortedLogFileInfos
        var firstIndexToDelete = NSNotFound
        
        var diskQuotaUsed: UInt64 = 0
        for (index, fileInfo) in sortedLogFileInfos.enumerated() {
            diskQuotaUsed += fileInfo.fileSize
            
            if diskQuotaUsed > logFilesDiskQuota {
                firstIndexToDelete = index
                break
            }
        }
        
        if firstIndexToDelete == NSNotFound {
            firstIndexToDelete = Int(maxinumNumberOfLogFiles)
        } else {
            firstIndexToDelete = min(firstIndexToDelete, Int(maxinumNumberOfLogFiles))
        }
        
        
        if firstIndexToDelete != NSNotFound,
           firstIndexToDelete < sortedLogFileInfos.count {
            for fileInfo in sortedLogFileInfos.suffix(from: firstIndexToDelete) {
                do {
                    try FileManager.default.removeItem(atPath: fileInfo.filePath)
                } catch {
                    DebugKit.log("DKLog: deleteFile error: \(error)")
                }
            }
        }
    }
    
    // MARK: Utils
    
}

struct DKLogFileInfo {
    let filePath: String
    let attrArchivedName = "dk.log.archived"

    let fileName: String

    var fileAttributes: [FileAttributeKey: AnyObject]? {
        var fileAttributes: [FileAttributeKey: AnyObject]? = nil
        do {
            fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath as String) as [FileAttributeKey: AnyObject]
        } catch {
            DebugKit.log("DKLog: create fileInfo \(error)")
        }
        
        return fileAttributes
    }

    var creationDate: Date {
        if let creationDate = fileAttributes?[.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }

    var modificationDate: Date {
        if let modificationDate = fileAttributes?[.modificationDate] as? Date {
            return modificationDate
        } else {
            return Date()
        }
    }

    var fileSize: UInt64 {
        if let fileSize = fileAttributes?[.size] as? UInt64 {
            return fileSize
        } else {
            return 0
        }
    }

    var age: TimeInterval {
        -creationDate.timeIntervalSinceNow
    }

//    lazy var isArchived: Bool { get }

    init(filePath: String) {
        self.filePath = filePath
        fileName = NSString(string: filePath).lastPathComponent
    }
    
    var description: String {
        "size: \(fileSize), modificationDate: \(modificationDate)"
    }

}

protocol DKFileReader {
    init(filePath: String)
    func read(atPath: String) -> ([DKLogMessage], [String])?
}


class DKFileReaderDefault: DKFileReader {

    let filePath: String
    let queue = DispatchQueue(label: "DKFileReadder")
    var logsDidUpdateCallback: (([DKLogMessage], [[String]]) -> Void)?
    
    private var logs: [DKLogMessage] = []
    
    private var keywords: [String] = []
    
    /// 不查询此列表中的关键词
    private var rejectKeywords: [String] = []
    
    /// 仅查询此列表中的关键词
    private var onlyKeywords: [String] = []
    
    private var searchText: String?
    
    
    required init(filePath: String) {
        
        self.filePath = filePath
        
        NotificationCenter.default.addObserver(forName: .DKFLLogDidLog, object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else { return }
            
            guard let message = notification.userInfo?[DKFileLoggerKey.message] as? DKLogMessage,
                  let path = notification.userInfo?[DKFileLoggerKey.path] as? String,
                  path == filePath else {
                return
            }
            
            self.rejectKeywords.forEach { keyword in
                if message.keyword.contains(keyword) {
                    return
                }
            }
            
            if self.onlyKeywords.count > 0 {
                let notContain = !message.keyword.components(separatedBy: "/").reduce(false) {
                    $0 || self.onlyKeywords.contains($1)
                }
                if notContain {
                    return
                }
            }
            
            self.updateLogs()
        }
        
        updateLogs()
    }
    
    // MARK: Public
    func removeRejectKeyword(keyword: String) {
        queue.async {
            if let index = self.rejectKeywords.firstIndex(of: keyword) {
                self.keywords.insert(self.rejectKeywords.remove(at: index), at: 0)
                self.filtration()
            }
        }
    }
    
    func addRejectKeyword(keyword: String) {
        queue.async {
            if let index = self.keywords.firstIndex(of: keyword) {
                self.rejectKeywords.append(self.keywords.remove(at: index))
                self.filtration()
            }
        }
    }
    
    func removeOnlyKeyword(keyword: String) {
        queue.async {
            if let index = self.onlyKeywords.firstIndex(of: keyword) {
                self.keywords.insert(self.onlyKeywords.remove(at: index), at: 0)
                self.filtration()
            }
        }
    }
    
    func addOnlyKeyword(keyword: String) {
        queue.async {
            if let index = self.keywords.firstIndex(of: keyword) {
                self.onlyKeywords.append(self.keywords.remove(at: index))
                self.filtration()
            }
        }
    }
    
    func updateSearch(text: String?) {
        queue.async {
            self.searchText = text
            self.filtration()
        }
    }
    
    func filtration() {
        let result = logs.filter { message in
            // 排除包含此关键词的log
            if rejectKeywords.count > 0 {
                if rejectKeywords.reduce(false, { $0 || message.keyword.contains($1) }) {
                    return false
                }
            }
            
            // 保留包含此关键词的log
            if onlyKeywords.count > 0 {
                if !onlyKeywords.reduce(true, { $0 && message.keyword.contains($1) }) {
                    return false
                }
            }
            
            // 保留包含此内容的log
            if let searchText = self.searchText, !searchText.isEmpty {
                if (!message.message.contains(searchText)) {
                    return false
                }
            }
            
            return true
        }
        
        DispatchQueue.main.async {
            if let callback = self.logsDidUpdateCallback {
                callback(result, [self.rejectKeywords, self.onlyKeywords, self.keywords])
            }
        }
    }
    
    
    // MARK: private
    private func updateLogs() {
        queue.async {
            guard let (newLogs, keywords) = self.read(atPath: self.filePath) else {
                return
            }
            
            self.logs = newLogs
            self.keywords = keywords.filter {
                !(self.rejectKeywords.contains($0) || self.onlyKeywords.contains($0))
            }
            self.filtration()
        }
    }
    
    func read(atPath: String) -> ([DKLogMessage], [String])? {
        guard let fileHandle = FileHandle(forReadingAtPath: atPath) else {
            return nil
        }
        
        let data = fileHandle.readDataToEndOfFile()
        
        let content = String(data: data, encoding: .utf8)
        
        let messageStringArray = content?.components(separatedBy: "\n")
        
        let jsonDecoder = JSONDecoder()
        var messages = messageStringArray?.reduce( [DKLogMessage](), { lastResult, message in
            if let messageData = message.data(using: .utf8),
               let logMessage = try? jsonDecoder.decode(DKLogMessage.self, from: messageData) {
                var result = Array(lastResult)
                result.append(logMessage)
                return result
            } else {
                return lastResult
            }
        })
        
        messages = messages?.sorted(by: { $1.date.compare($0.date) == .orderedAscending })
        
        let keywords = messages?.reduce(Set<String>(), { result, logMessage in
            result.union(logMessage.keyword.components(separatedBy: "/"))
        })
        
        return (messages ?? [], keywords?.sorted() ?? [])
    }
}
