//
//  ContentView.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var logger = SimpleLogger.instance
	@State var message = "I'm Heeeere"
	
	var body: some View {
		VStack() {
			Text("Connected: \(logger.isConnected ? "Yes" : "No")")
			TextField("Message", text: $message)
			
			Button("Send") {
				SimpleLogger.instance.send(message)
			}
		}
		
		
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
