//
//  Listener.swift
//  QuickLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import Foundation

import Foundation
import Network

public class Server: ObservableObject {
	public static var instance: Server!
	
	let port: NWEndpoint.Port
	let listener: NWListener
	
	public var allConnections: [ServerConnection] { connectionsByID.values.sorted() }
	
	public static var defaultPort: UInt16 = 8888
	private var connectionsByID: [Int: ServerConnection] = [:]
	
	public static func start(at port: UInt16 = Server.defaultPort) throws {
		if let current = instance {
			if current.port.rawValue == port { return }			// already running
			
			current.stop()
		}
		
		instance = Server(port: port)
		try instance.start()
	}
	
	init(port: UInt16) {
		self.port = NWEndpoint.Port(rawValue: port)!
		listener = try! NWListener(using: .tcp, on: self.port)
	}
	
	func start() throws {
		print("Server starting...")
		listener.stateUpdateHandler = self.stateDidChange(to:)
		listener.newConnectionHandler = self.didAccept(nwConnection:)
		listener.start(queue: .main)
	}
	
	func stateDidChange(to newState: NWListener.State) {
		switch newState {
		case .ready:
			print("Server ready.")
		case .failed(let error):
			print("Server failure, error: \(error)")
			exit(EXIT_FAILURE)
		default:
			break
		}
	}
	
	private func didAccept(nwConnection: NWConnection) {
		let connection = ServerConnection(nwConnection: nwConnection)
		self.connectionsByID[connection.id] = connection
		connection.didStopCallback = { _ in
			self.connectionDidStop(connection)
		}
		connection.start()
		DispatchQueue.main.async { self.objectWillChange.send() }
	}
	
	private func connectionDidStop(_ connection: ServerConnection) {
		self.connectionsByID.removeValue(forKey: connection.id)
		print("server did close connection \(connection.id)")
	}
	
	private func stop() {
		self.listener.stateUpdateHandler = nil
		self.listener.newConnectionHandler = nil
		self.listener.cancel()
		for connection in self.connectionsByID.values {
			connection.didStopCallback = nil
			connection.stop()
		}
		self.connectionsByID.removeAll()
	}
}
