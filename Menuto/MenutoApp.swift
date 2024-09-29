//
//  MenutoApp.swift
//  Menuto
//
//  Created by Christian Nagel on 20.09.24.
//

import SwiftUI
import UserNotifications

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
            .onAppear() {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
                
            }
            .onReceive(timer) { input in
                if (!running) { return };
                
                // Check if timer ran out
                if (timeRemaining <= 0) {
                    // Send notification
                    let content = UNMutableNotificationContent()
                    content.title = "Your timer ran out"
                    content.sound = .default

                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

                    UNUserNotificationCenter.current().add(request)
                    
                    
                    running = false
                    return
                }
                
                timeRemaining -= 1
            }
            
        }.menuBarExtraStyle(.window)
    }
    
}
