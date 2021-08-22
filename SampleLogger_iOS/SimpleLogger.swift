//
//  SimpleLogger.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation
import Network

class SimpleLogger {
	static public var instance: SimpleLogger!
	public static var defaultPort: UInt16 = 8888
	let queue = DispatchQueue(label: "simpleLoggerQueue")
	
	static public func start(host: String, on port: UInt16 = SimpleLogger.defaultPort) {
		instance = SimpleLogger(host: host, port: port)
		instance.start()
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
		print("connection will start")
		nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
		nwConnection.stateUpdateHandler = connectionStateDidChange(to:)
		nwConnection.start(queue: queue)
		setupReceive()
	}
	
	func poll(after: TimeInterval = 1) {
		DispatchQueue.main.asyncAfter(deadline: .now() + after) {
			self.start()
		}
	}
	
	private func connectionStateDidChange(to state: NWConnection.State) {
		switch state {
		case .waiting(let error):
			connectionDidFail(error: error)
			poll(after: 1)
		case .ready:
			print("Client connection ready")
			send("Hello")
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
		if let data = string.data(using: .utf8) {
			send(data: data)
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
