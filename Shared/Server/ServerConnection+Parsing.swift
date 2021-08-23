//
//  ServerConnection+Parsing.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import Foundation

extension ServerConnection {
	static let leftBracket = "[".data(using: .utf8)!
	static let rightBracket = "]".data(using: .utf8)!
	
	func parse(data: Data) {
		let raw = Self.leftBracket + data + Self.rightBracket
		
		do {
			guard let json = try JSONSerialization.jsonObject(with: raw, options: [.fragmentsAllowed]) as? [[String: Any]] else {
				print("Unable to parse: \(String(data: data, encoding: .utf8) ?? "some data")")
				return
			}
			
			for dict in json {
				guard let kind = dict["kind"] as? String else {
					print("Unable to parse: \(dict)")
					continue
				}
				print("Got: \(kind)")
			}
		} catch {
			print("Unable to parse: \(String(data: data, encoding: .utf8) ?? "some data"), \n\(error)")
		}
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
}
