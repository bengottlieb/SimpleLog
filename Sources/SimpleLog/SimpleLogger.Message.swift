//
//  SimpleLog.Message.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation

protocol SimpleMessage: Codable {
//	static var kind: SimpleLogger.MessageKind { get }
}

extension SimpleMessage {
	var data: Data? {
		guard let raw = try? JSONEncoder().encode(self) else { return nil }
//
//		let kindString = "<\(Self.kind.rawValue)>"
//		guard let kind = kindString.data(using: .utf8) else { return nil }
//
//		return kind + raw
		return raw + ",".data(using: .utf8)!
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
