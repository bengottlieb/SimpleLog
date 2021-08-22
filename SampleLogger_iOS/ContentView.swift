//
//  ContentView.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ContentView: View {
	@State var message = ""
	
	var body: some View {
		VStack() {
			TextField("Message", text: $message)
			
			Button("Send") { SimpleLogger.instance.send(message) }
		}
		
		
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
