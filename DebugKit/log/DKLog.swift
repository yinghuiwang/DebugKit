//
//  DKLog.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/29.
//

import Foundation

open class DKLog: NSObject {
    
    let loggingQueue = DispatchQueue(label: "DebugKit")
    let loggingGroup = DispatchGroup()
    var loggers:[DKLogger] = []
    let dateFormatter: DateFormatter
    
    @objc public static let share = DKLog()
    private override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        
        super.init()
        loggers.append(DKFileLogger(manager: DKFileManagerDefault(), queue: nil))
    }
    
    
    /// 添加一条日志
    /// - Parameters:
    ///   - keyword: 关键词，方便查询搜索，多个关键词可以采用 “keyword1/keyword2”
    ///   - message: 日志详情
    @objc public func log(keyword: String, message: String) {
        log(keyword: keyword, summary: nil, message: message)
    }
    
    @objc public func log(keyword: String, summary: String?, message: String) {
        DebugKit.log("[\(DKDebugLogKey.life)] add log start");
        loggingQueue.async { [weak self] in
            guard let self = self else { return }
            let message = DKLogMessage(message: message,
                                       keyword: keyword,
                                       summary: summary,
                                       timestamp: self.dateFormatter.string(from: Date()),
                                       date: Date())
            self.log(message: message)
        }
    }
    
    private func log(message: DKLogMessage) {
        loggers.forEach { logger in
            logger.log(message: message)
        }
    }
    
    func add(logger: DKLogger) {
        loggers.append(logger)
    }
    
    func remover(logger: DKLogger) {
        loggers = loggers.filter { $0.name != logger.name }
    }
}


struct DKLogMessage: Codable {
    let message: String
    let keyword: String
    let summary: String?
    let timestamp: String
    let date: Date
}

protocol DKLogFormatter {
    func format(message: DKLogMessage) -> String
}

protocol DKLogger {
    var name: String { get }
    var logFromatter: DKLogFormatter? {get set}
    func log(message: DKLogMessage) -> Void
}

extension DKDebugLogKey {
    static let life = "LIFE"
}
