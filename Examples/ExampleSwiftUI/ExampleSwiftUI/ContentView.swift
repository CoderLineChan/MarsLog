//
//  ContentView.swift
//  ExampleSwiftUI
//
//  Created by CoderChan on 2026/5/14.
//

import SwiftUI
import MarsLog

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            _ = MarsLogger.shared()
        }
    }
}

#Preview {
    ContentView()
}
