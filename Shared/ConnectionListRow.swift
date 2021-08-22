//
//  ConnectionListRow.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ConnectionListRow: View {
	@ObservedObject var connection: ServerConnection
	var body: some View {
		VStack() {
			Text("Connection #\(connection.id)")
			Text(connection.receivedMessages.last ?? "--")
				.foregroundColor(Color(.secondaryLabelColor))
		}
	}
}

