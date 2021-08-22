//
//  ServerConnection.swift
//  QuickLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation
import Network

public class ServerConnection: ObservableObject, Identifiable, Comparable {
	let maxMessageSize = 65536			// max for TCP
	
	private static var nextID: Int = 0
	let connection: NWConnection
	public let id: Int
	var state: NWConnection.State { connection.state }
	var receivedMessages: [String] = []
	
	init(nwConnection: NWConnection) {
		connection = nwConnection
		id = ServerConnection.nextID
		ServerConnection.nextID += 1
	}
	
	var didStopCallback: ((Error?) -> Void)?
	
	func start() {
		connection.stateUpdateHandler = stateDidChange(to:)
		setupReceive()
		connection.start(queue: .main)
	}
	
	private func stateDidChange(to state: NWConnection.State) {
		switch state {
		case .waiting(let error):
			connectionDidFail(error: error)
		case .ready:
			break
		case .failed(let error):
			connectionDidFail(error: error)
		default:
			break
		}
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
	
	private func setupReceive() {
		connection.receive(minimumIncompleteLength: 1, maximumLength: maxMessageSize) { data, _, isComplete, error in
			if let data = data, !data.isEmpty {
				if let message = String(data: data, encoding: .utf8) {
					self.receivedMessages.append(message)
				}
				DispatchQueue.main.async { self.objectWillChange.send() }
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
	
	
	func send(data: Data) {
		self.connection.send(content: data, completion: .contentProcessed( { error in
			if let error = error {
				self.connectionDidFail(error: error)
				return
			}
		}))
	}
	
	func stop() {
		print("connection \(id) will stop")
	}
	
	private func connectionDidFail(error: Error) {
		print("connection \(id) did fail, error: \(error)")
		stop(error: error)
	}
	
	private func connectionDidEnd() {
		print("connection \(id) did end")
		stop(error: nil)
	}
	
	private func stop(error: Error?) {
		connection.stateUpdateHandler = nil
		connection.cancel()
		if let didStopCallback = didStopCallback {
			self.didStopCallback = nil
			didStopCallback(error)
		}
	}
}

extension ServerConnection {
	public static func ==(lhs: ServerConnection, rhs: ServerConnection) -> Bool {
		lhs.id == rhs.id
	}

	public static func <(lhs: ServerConnection, rhs: ServerConnection) -> Bool {
		lhs.id < rhs.id
	}

}
