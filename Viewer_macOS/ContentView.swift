//
//  ContentView.swift
//  SimpleLog
//
//  Created by Ben Gottlieb on 8/22/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MessageCenterScreen()
			.frame(minWidth: 300, minHeight: 500)
			.frame(maxWidth: .infinity)
			.frame(maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
