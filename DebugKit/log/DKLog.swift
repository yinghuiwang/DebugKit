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
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        
        super.init()
        loggers.append(DKFileLogger(manager: DKFileManagerDefault(), queue: nil))
    }
    
    @objc public func log(keyword: String, message: String) {
        let message = DKLogMessage(message: message,
                                   keyword: keyword,
                                   timestamp: dateFormatter.string(from: Date()))
        log(message: message)
    }
    
    func log(message: DKLogMessage) {
        loggers.forEach { logger in
            loggingQueue.async {
                logger.log(message: message)
            }
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
    let timestamp: String
    
//    enum CodingKeys: String, CodingKey {
//        case message
//        case keyword
//        case timestamp
//    }
//    
//    init(from decoder: Decoder) throws {
//        
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        
//    }
}

protocol DKLogFormatter {
    func format(message: DKLogMessage) -> String
}

protocol DKLogger {
    var name: String { get }
    var logFromatter: DKLogFormatter? {get set}
    func log(message: DKLogMessage) -> Void
}
