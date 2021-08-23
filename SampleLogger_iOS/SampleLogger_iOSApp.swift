//
//  SampleLogger_iOSApp.swift
//  SampleLogger_iOS
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

@main
struct SampleLogger_iOSApp: App {
	init() {
		SimpleLogger.configure(host: "localhost", on: 8888)
	}
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
