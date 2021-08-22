//
//  SimpleLogApp.swift
//  SimpleLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

@main
struct SimpleLogApp: App {
	init() {
		do {
			try Server.start()
		} catch {
			print("Failed to start server: \(error)")
		}
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
