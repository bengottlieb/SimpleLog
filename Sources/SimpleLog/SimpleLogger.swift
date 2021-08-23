//
//  SimpleLogger.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation
import Network

public class SimpleLogger {
	static public var instance: SimpleLogger!
	public static var defaultPort: UInt16 = 8888
	let queue = DispatchQueue(label: "simpleLoggerQueue")
	var pendingMessages: [SimpleMessage] = []
	public var isConnected: Bool { nwConnection.state == .ready }
	var isPolling = false
	
	static public func configure(host: String, on port: UInt16 = SimpleLogger.defaultPort) {
		instance = SimpleLogger(host: host, port: port)
	}
	
	let host: NWEndpoint.Host
	let port: NWEndpoint.Port
	var nwConnection: NWConnection!
	
	init(host: String, port: UInt16) {
		self.host = NWEndpoint.Host(host)
		self.port = NWEndpoint.Port(rawValue: port)!
	}
	
	func start() {
		if nwConnection?.state == .ready { return }
		nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
		nwConnection.stateUpdateHandler = connectionStateDidChange(to:)
		nwConnection.start(queue: queue)
		setupReceive()
	}
	
	func poll(after: TimeInterval = 1) {
		if isPolling { return }
		isPolling = true
		DispatchQueue.main.asyncAfter(deadline: .now() + after) {
			self.start()
			if self.isConnected { self.isPolling = false }
		}
	}
	
	private func connectionStateDidChange(to state: NWConnection.State) {
		switch state {
		case .waiting(let error):
			connectionDidFail(error: error)
			if isPolling { poll(after: 1) }
		case .ready:
			send(SimpleLogger.Info(), first: true)
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
			if !isPolling { poll(after: 0.5) }
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
		self.poll(after: 1)
	}
	
	private func stop(error: Error?) {
		self.nwConnection.stateUpdateHandler = nil
		self.nwConnection.cancel()
	}
}
