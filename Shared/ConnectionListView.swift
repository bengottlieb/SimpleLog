//
//  ConnectionListView.swift
//  Viewer_macOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ConnectionListView: View {
	@ObservedObject var server = Server.instance
    var body: some View {
		ForEach(server.allConnections) { connection in
			ConnectionListRow(connection: connection)
		}
	}
}

struct ConnectionListView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionListView()
    }
}
