//
//  SimpleLogger.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation
import Network
import MultipeerConnectivity

public class SimpleLogger: NSObject, ObservableObject {
	static public var instance: SimpleLogger!
	public static var defaultPort: UInt16 = 8888
	let queue = DispatchQueue(label: "simpleLoggerQueue")
	var pendingMessages: [SimpleMessage] = []
	public var isConnected: Bool { nwConnection?.state == .ready }
	var isPolling = false
	lazy var peerID = generateLocalPeerID()
	var browser: MCNearbyServiceBrowser?

	static public func configure(host: String? = nil, on port: UInt16? = nil) {
		instance = SimpleLogger(host: host, port: port)
	}
	
	var host: NWEndpoint.Host?
	var port: NWEndpoint.Port?
	var nwConnection: NWConnection!
	
	init(host: String?, port: UInt16?) {
		super.init()
		if let host = host, let port = port {
			load(host: host, port: port)
		} else {
			browse()
		}
	}

	func load(host: String, port: UInt16) {
		self.host = NWEndpoint.Host(host)
		self.port = NWEndpoint.Port(rawValue: port)
	}
	
	func start() {
		guard let host = host, let port = port, nwConnection?.state != .ready else { return }
		nwConnection = NWConnection(host: host, port: port, using: .tcp)
		nwConnection.stateUpdateHandler = connectionStateDidChange(to:)
		nwConnection.start(queue: queue)
		setupReceive()
	}
	
	func poll(after: TimeInterval = 1, firstPoll: Bool = false) {
		isPolling = true
		DispatchQueue.main.asyncAfter(deadline: .now() + (firstPoll ? 0.01 : after)) {
			self.start()
		}
	}
	
	private func connectionStateDidChange(to state: NWConnection.State) {
		switch state {
		case .waiting(let error):
			connectionDidFail(error: error)
			if isPolling {
				poll(after: 1)
			} else {
				DispatchQueue.main.async { self.objectWillChange.send() }
			}
		case .ready:
			isPolling = false
			send(SimpleLogger.Info(), first: true)
			DispatchQueue.main.async { self.objectWillChange.send() }
		case .failed(let error):
			connectionDidFail(error: error)
		default:
			break
		}
	}
	
	private func setupReceive() {
		nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
			if let data = data, !data.isEmpty {
				let message = String(data: data, encoding: .utf8)
				print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
			}
			if isComplete {
				self.connectionDidEnd()
			} else if let error = error {
				self.connectionDidFail(error: error)
			} else {
				self.setupReceive()
			}
		}
	}
	
	func send(_ string: String) {
		send(Text(text: string))
	}
	
	func send<Message: SimpleMessage>(_ message: Message, first: Bool = false) {
		if first {
			pendingMessages.insert(message, at: 0)
		} else {
			pendingMessages.append(message)
		}
		if !isConnected {
			if !isPolling { poll(after: 1, firstPoll: true) }
		} else {
			handlePendingMessages()
		}
	}
	
	func handlePendingMessages() {
		for message in pendingMessages {
			if let data = message.data {
				send(data: data)
				if !pendingMessages.isEmpty { pendingMessages.remove(at: 0) }
			} else {
				print("Failed to send message: \(message)")
				break
			}
		}
	}
	
	func send(data: Data) {
		nwConnection.send(content: data, completion: .contentProcessed( { error in
			if let error = error {
				self.connectionDidFail(error: error)
				return
			}
			print("connection did send, data: \(data as NSData)")
		}))
	}
	
	func stop() {
		print("connection will stop")
		stop(error: nil)
	}
	
	private func connectionDidFail(error: Error) {
		print("connection did fail, error: \(error)")
		self.stop(error: error)
	}
	
	private func connectionDidEnd() {
		print("connection did end")
		self.stop(error: nil)
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
	
	private func stop(error: Error?) {
		self.nwConnection?.stateUpdateHandler = nil
		self.nwConnection?.cancel()
		self.nwConnection = nil
	}
}
