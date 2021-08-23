//
//  SimpleLog.Message.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation

protocol SimpleMessage: Codable {
	var kind: SimpleLogger.MessageKind { get }
//	static var kind: SimpleLogger.MessageKind { get }
}

fileprivate let quoteData = "\"".data(using: .utf8)!
fileprivate let quoteCommaData = "\",".data(using: .utf8)!
fileprivate let commaData = ",".data(using: .utf8)!

extension SimpleMessage {
	var data: Data? {
		if let message = self as? SimpleLogger.Text {
			return quoteData + message.text.data(using: .utf8)! + quoteCommaData
		}
		guard let raw = try? JSONEncoder().encode(self) else { return nil }
//
//		let kindString = "<\(Self.kind.rawValue)>"
//		guard let kind = kindString.data(using: .utf8) else { return nil }
//
//		return kind + raw
		return raw + commaData
	}
}

extension SimpleLogger {
	enum MessageKind: String, Codable {
		case text, info
	}
	
	public struct Text: SimpleMessage {
		var kind: MessageKind = .text
		let text: String
	}
}
