//
//  SimpleLogger+Browsing.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/23/21.
//

import Foundation
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
		self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: Self.serviceType)
		self.browser?.delegate = self
		self.browser?.startBrowsingForPeers()
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		print(info)
		if let host = info?["host"], let portString = info?["port"], let port = UInt16(portString) {
			load(host: host, port: port)
		}
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print("failed to start browsing: \(error)")
		self.browser = nil
	}
}
