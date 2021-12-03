//
//  DKFileLogger.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/2.
//

import Foundation


extension Notification.Name {
    static let DKFLLogDidLog = Notification.Name("DKFileLoggerDidLog")
    static let DKFLLogCreatedLogFile = Notification.Name("DKFLLogCreatedLogFile")
}

enum DKFileLoggerKey: String {
    case messagesData
    case path
    case rejectKeywords
    case onlyKeywords
    case searchText
}

class DKFileLogger: NSObject, DKLogger {
    
    /// 2 MB
    let defaultLogMaxFileSize      = 1024 * 1024 * 2
    
    var name: String = "fileLogger"
    
    var logFromatter: DKLogFormatter?
    
    let logFileManager: DKLogFileManager
    let queue: DispatchQueue
    private var fromLaunchCreatedFile = false
    private var _currentLogFileHandle: FileHandle?
    private var _currentLogFileInfo: DKLogFileInfo?
    
    // 10KB
    let cacheDataMaxSize = 10 * 1024
    /// 延迟存储最长时间，单位毫秒
    let cacheDataMaxDuration = 500
    private var cacheData = Data()
    private var cacheTimer: DispatchSourceTimer?
    
    init(manager: DKLogFileManager, queue: DispatchQueue?) {
        self.queue = queue ?? DispatchQueue(label: "DKFileLogger")
        logFileManager = manager
        logFromatter = DKFileFormatter(dateFormatter: nil)
        super.init()
    }
    
    
    // MARK: DKLogger Protocol
    func log(message: DKLogMessage) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let data = self.data(logMessage: message), data.count > 0 else {
                return
            }
            
            // 没有达到缓存的最大阈值，先缓存，不写文件，减少磁盘文件的IO操作
            guard let needSaveData = self.cacheLogData(data: data) else {
                // 延迟存储，如果在0.5秒后，cacheData还没有达到阈值，则直接将cacheData存到磁盘文件
                self.delaySaveCacheData()
                return
            }
            
            self.logData(data: needSaveData)
        }
    }
    
    // MARK: Internal
    private func delaySaveCacheData() {
        if cacheTimer == nil {
            let timer = DispatchSource.makeTimerSource(flags: [], queue: self.queue)
            timer.setEventHandler { [weak self] in
                guard let self = self else { return }
                if (self.cacheData.count > 0) {
                    self.logData(data: self.cacheData)
                    self.cacheData.removeAll()
                } else {
                    self.cacheTimer?.cancel()
                    self.cacheTimer = nil
                }
            }
            timer.schedule(deadline: DispatchTime.now() + .milliseconds(cacheDataMaxDuration),
                           repeating: .milliseconds(cacheDataMaxDuration),
                           leeway: .milliseconds(1))
            timer.activate()
            cacheTimer = timer
        }
    }
    
    private func cacheLogData(data: Data) -> Data? {
        cacheData.append(data)
        if cacheData.count >= cacheDataMaxSize {
            let logData = self.cacheData
            self.cacheData.removeAll()
            return logData
        }
        return nil
    }
    
    private func logData(data: Data) {
        do {
            DebugKit.log("[\(DKDebugLogKey.life)][\(DKDebugLogKey.file)] write start");
            let handle = self.currentLogFileHandle()
            if #available(iOS 13.4, *) {
                try handle.seekToEnd()
                handle.write(data)
            } else {
                handle.seekToEndOfFile()
                handle.write(data)
            }
            DebugKit.log("[\(DKDebugLogKey.life)][\(DKDebugLogKey.file)] write end");
        } catch {
            DebugKit.log("DKLog: \(error)")
        }
        
        // 通知
        if let filePath = self._currentLogFileInfo?.filePath {
            NotificationCenter.default.post(name: .DKFLLogDidLog, object: nil,
                                            userInfo: [
                                                DKFileLoggerKey.messagesData: data,
                                                DKFileLoggerKey.path: filePath
                                            ])
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
    
    var maxinumNumberOfLogFiles: UInt = 40 // 40 Files
    var logFilesDiskQuota: UInt64 = 40 * 1024 * 1024 // 40 MB
    
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
        
        NotificationCenter.default.post(name: .DKFLLogCreatedLogFile, object: nil,
                                        userInfo: [
                                            DKFileLoggerKey.path: filePath
                                        ])
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
    func read(atPath: String) -> [DKLogMessage]?
}


class DKFileReaderDefault: DKFileReader {

    let filePath: String
    let queue = DispatchQueue(label: "DKFileReadder")
    var logsDidUpdateCallback: (([DKLogMessage], [[String]]) -> Void)?
    
    private var logs: [DKLogMessage] = []
    private var keywordsSet: Set<String> = Set<String>()
    private var keywords: [String] {
        keywordsSet.sorted().filter { !(self.rejectKeywords.contains($0) || self.onlyKeywords.contains($0)) }
    }
    
    private var needRefreshUI = false
    private var refreshUITimer: DispatchSourceTimer?
    
    /// 不查询此列表中的关键词
    private var rejectKeywords: [String] {
        didSet {
            DebugKit.userDefault()?.setValue(rejectKeywords, forKey: DKFileLoggerKey.rejectKeywords.rawValue)
        }
    }
    
    /// 仅查询此列表中的关键词
    private var onlyKeywords: [String] {
        didSet {
            DebugKit.userDefault()?.setValue(onlyKeywords, forKey: DKFileLoggerKey.onlyKeywords.rawValue)
        }
    }
    
    private(set) var searchText: String? {
        didSet {
            DebugKit.userDefault()?.setValue(searchText, forKey: DKFileLoggerKey.searchText.rawValue)
        }
    }
    
    
    required init(filePath: String) {
        
        self.filePath = filePath
        
        self.rejectKeywords = DebugKit.userDefault()?.stringArray(forKey: DKFileLoggerKey.rejectKeywords.rawValue) ?? []
        self.onlyKeywords = DebugKit.userDefault()?.stringArray(forKey: DKFileLoggerKey.onlyKeywords.rawValue) ?? []
        self.searchText =  DebugKit.userDefault()?.string(forKey: DKFileLoggerKey.searchText.rawValue)
    }
    
    // MARK: Public
    
    /// 开始添加log通知监听
    func startAddLogListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddLog(notification:)), name: .DKFLLogDidLog, object: nil)
        updateLogs()
    }
    
    /// 停止添加log通知监听
    func stopAddLogListener() {
        NotificationCenter.default.removeObserver(self, name: .DKFLLogDidLog, object: nil)
    }
    
    func removeRejectKeyword(keyword: String) {
        queue.async {
            if let index = self.rejectKeywords.firstIndex(of: keyword) {
                self.rejectKeywords.remove(at: index)
                self.refrashUIIfNeed(atOnce: true)
            }
        }
    }
    
    func addRejectKeyword(keyword: String) {
        queue.async {
            self.rejectKeywords.append(keyword)
            self.refrashUIIfNeed(atOnce: true)
        }
    }
    
    func removeOnlyKeyword(keyword: String) {
        queue.async {
            if let index = self.onlyKeywords.firstIndex(of: keyword) {
                self.onlyKeywords.remove(at: index)
                self.refrashUIIfNeed(atOnce: true)
            }
        }
    }
    
    func addOnlyKeyword(keyword: String) {
        queue.async {
            self.onlyKeywords.append(keyword)
            self.refrashUIIfNeed(atOnce: true)
        }
    }
    
    func updateSearch(text: String?) {
        queue.async {
            self.searchText = text
            self.refrashUIIfNeed()
        }
    }
    
    // MARK: private
    private func updateLogs() {
        queue.async {
            guard let newLogs = self.read(atPath: self.filePath) else {
                return
            }
            
            self.logs = newLogs
            self.keywordsSet = self.keywordsSet.union(self.keywords(messages: newLogs))
            self.filtration()
        }
    }
    
    internal func read(atPath: String) -> [DKLogMessage]? {
        guard let fileHandle = FileHandle(forReadingAtPath: atPath) else {
            DebugKit.showToast(text: "文件读取失败\n文件可能过期被移除")
            return nil
        }
        
        DebugKit.log("[\(DKDebugLogKey.life)][\(DKDebugLogKey.file)] read start");
        let data = fileHandle.readDataToEndOfFile()
        DebugKit.log("[\(DKDebugLogKey.life)][\(DKDebugLogKey.file)] read end");
        

        var messages = decode(data: data)
        messages.sort(by: { $1.date.compare($0.date) == .orderedAscending })
        
        return messages
    }
    
    private func keywords(messages: [DKLogMessage]) -> Set<String> {
        return messages.reduce(Set<String>()) { result, message in
            let keywords = message.keyword.components(separatedBy: "/").filter { keyword in
                if keyword.count <= 0 {
                    return false
                }
                return true
            }
            return result.union(keywords)
        }
    }
    
    private func decode(data: Data) -> [DKLogMessage] {
        let content = String(data: data, encoding: .utf8)
        
        let messageStringArray = content?.components(separatedBy: "\n")
        
        let jsonDecoder = JSONDecoder()
        let messages = messageStringArray?.reduce( [DKLogMessage](), { lastResult, message in
            if let messageData = message.data(using: .utf8),
               let logMessage = try? jsonDecoder.decode(DKLogMessage.self, from: messageData) {
                var result = Array(lastResult)
                result.append(logMessage)
                return result
            } else {
                return lastResult
            }
        })
        return messages ?? []
    }
    // MARK:
    @objc private func didAddLog(notification: Notification) {
        queue.async {
            guard let messagesData = notification.userInfo?[DKFileLoggerKey.messagesData] as? Data,
                  let path = notification.userInfo?[DKFileLoggerKey.path] as? String,
                  path == self.filePath else {
                return
            }
            
            let messages = self.decode(data: messagesData)
            self.keywordsSet = self.keywordsSet.union(self.keywords(messages: messages))
            self.logs.insert(contentsOf: messages, at: 0)
            
            let needRefrashUI = messages.reduce(false) { result, message in
                do { // 有排除关键词，此消息包含在关键词内，不用刷新UI
                    let isRejectMessage = self.rejectKeywords.reduce(false) {
                        $0 || message.keyword.contains($1)
                    }
                    
                    if isRejectMessage {
                        return result || false
                    }
                }
                
                do {  // 有筛选关键词，此消息不包含在关键词内，不用刷新UI
                    if self.onlyKeywords.count > 0 {
                        let notContain = !message.keyword.components(separatedBy: "/").reduce(false) {
                            $0 || self.onlyKeywords.contains($1)
                        }
                        if notContain {
                            return result || false
                        }
                    }
                }
                
                return result || true
            }
            
            if (needRefrashUI) {
                self.refrashUIIfNeed()
            }
           
        }
    }
    
    private func refrashUIIfNeed(atOnce: Bool = false) {
        
        if atOnce { // 立刻刷新
            if let refreshUITimer = self.refreshUITimer {
                refreshUITimer.cancel()
                self.refreshUITimer = nil
            }
        }
        
        needRefreshUI = true
        if refreshUITimer == nil {
            let timer = DispatchSource.makeTimerSource(flags: [], queue: self.queue)
            timer.setEventHandler { [weak self] in
                guard let self = self else { return }
                if (self.needRefreshUI) {
                    self.filtration()
                    self.needRefreshUI = false;
                } else {
                    self.refreshUITimer?.cancel()
                    self.refreshUITimer = nil
                }
            }
            timer.schedule(deadline: DispatchTime.now() + .milliseconds(500),
                           repeating: .milliseconds(500),
                           leeway: .milliseconds(1))
            timer.activate()
            refreshUITimer = timer
            self.filtration()
        }
    }
    
    private func filtration() {
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
}

extension DKDebugLogKey {
    static let file = "FILE"
}
