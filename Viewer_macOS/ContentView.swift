//
//  ContentView.swift
//  SimpleLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ContentView: View {
	var title: String {
		if let ip = Server.instance.hostAddress {
			return "SimpleLogger @ \(ip)"
		}
		return "SimpleLogger"
	}
	
	var body: some View {
		MessageCenterScreen()
			.frame(minWidth: 300, minHeight: 500)
			.frame(maxWidth: .infinity)
			.frame(maxHeight: .infinity)
			.navigationTitle(title)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
