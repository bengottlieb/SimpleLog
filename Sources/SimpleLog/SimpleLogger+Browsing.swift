//
//  SimpleLogger+Browsing.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import Foundation

#if os(watchOS)
extension SimpleLogger {
	func browse() {
		print("Browsing not supported on watchOS")
	}
}
#else
import MultipeerConnectivity

#if canImport(WatchKit)
	import WatchKit
#endif

extension SimpleLogger: MCNearbyServiceBrowserDelegate {
	public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
	
	static let serviceType = "SAI-SimpleLog"
	
	func generateLocalPeerID() -> MCPeerID {
		#if os(iOS)
			return MCPeerID(displayName: UIDevice.current.name)
		#elseif os(watchOS)
			return MCPeerID(displayName: WKInterfaceDevice.current().name)
		#elseif os(macOS)
			return MCPeerID(displayName: Host.current().localizedName ?? "My Mac")
		#endif
		
	}
	
	func browse() {
		let browser = MCNearbyServiceBrowser(peer: self.generateLocalPeerID(), serviceType: Self.serviceType)
		browser.delegate = self
		browser.startBrowsingForPeers()
		
		self.browser = browser
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		if let host = info?["host"], let portString = info?["port"], let port = UInt16(portString) {
			load(host: host, port: port)
		}
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print("failed to start browsing: \(error)")
		self.browser = nil
	}
}
#endif
