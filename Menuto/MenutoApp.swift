//
//  MenutoApp.swift
//  Menuto
//
//  Created by Christian Nagel on 20.09.24.
//

import SwiftUI

@main
struct MenutoApp: App {
    @AppStorage("setMinutes") var setMinutes: Int = 5;
    
    @State private var timeRemaining: Int = 60 // Timer duration in seconds
    @State private var running: Bool = false;
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        MenuBarExtra(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60)) {
            VStack {
                
                LabeledContent {
                    TextField("Enter number", text: Binding(
                        get: { String(self.setMinutes) },
                        set: { newValue in
                            if let intValue = Int(newValue) {
                                self.setMinutes = intValue
                            } else {
                                self.setMinutes = 0
                            }
                        }
                    ))
                } label: {
                    Text("Minutes")
                }
                
                Divider()
                HStack {
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }.keyboardShortcut("q")
                    Spacer()
                    Button("Start") {
                        running = true;
                    }
                }
            }
            .padding()
            .onReceive(timer) { input in
                if (!running) { return };
                timeRemaining -= 1
            }
            
        }.menuBarExtraStyle(.window)
    }
    
}
