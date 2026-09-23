//
//  AppLogger.swift
//  ImageFeed
//
//  Created by Adilkhan on 23/9/26.
//
import Logging

enum LogCategory: String {
    case app, network, decoding, request
}

enum AppLogger {
    static func setup() {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .debug
            return handler
        }
    }
    
    static func info(_ message: String,
                     metadata: [String: String]? = nil,
                     category: LogCategory = .app) {
        
        Logger(label: category.rawValue)
            .info("\(message)", metadata: metadata?.mapValues{.string($0)})
    }
    
    static func warning(_ message: String, metadata: [String: String]? = nil, category: LogCategory = .app) {
        Logger(label: category.rawValue)
            .warning("\(message)",metadata: metadata?.mapValues{.string($0)})
    }
    
    static func error(_ message: String,
                      metadata: [String: String]? = nil,
                      category: LogCategory = .app) {
        
        Logger(label: category.rawValue)
            .error("\(message)", metadata: metadata?.mapValues{.string($0)})
    }
    
    static func debug(_ message: String,
                      metadata: [String: String]? = nil,
                      category: LogCategory = .app) {
        
        Logger(label: category.rawValue)
            .debug("\(message)", metadata: metadata?.mapValues{.string($0)})
    }
}
