//
//  SimpleLogger.DeviceInfo.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation
#if canImport(UIKit)
	import UIKit
#endif

#if canImport(WatchKit)
	import WatchKit
#endif

extension SimpleLogger {
	
	public struct Info: SimpleMessage {
		var kind: MessageKind = .info
		var deviceName: String
		var deviceKind: String
		var deviceID: String
		var identifier: String

		init() {
			#if os(iOS)
				deviceName = UIDevice.current.name
				deviceKind = UIDevice.current.model
				deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "--"
				identifier = Bundle.main.bundleIdentifier ?? "??"
			#endif
			
			#if os(watchOS)
				deviceName = WKInterfaceDevice.current().name
				deviceKind = WKInterfaceDevice.current().model
				deviceID = WKInterfaceDevice.current().identifierForVendor?.uuidString ?? ""
				identifier = Bundle.main.bundleIdentifier ?? "??"
			#endif
			
			#if os(macOS)
			
			#endif
		}
	}

}
