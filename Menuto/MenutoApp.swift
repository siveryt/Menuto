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
        
        let secondsRemaining = Binding(
            get: { String(self.timeRemaining%60) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    
                    let hoursLeftOnTimer = Int(self.timeRemaining/3600)
                    let minutesLeftOnTimer = Int(self.timeRemaining/60%60)
                    let newSeconds = intValue
                    self.timeRemaining = hoursLeftOnTimer * 3600 + minutesLeftOnTimer * 60 + newSeconds
                }
            }
        )
        
        let minutesRemaining = Binding(
            get: { String(self.timeRemaining/60%60) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    let hoursLeftOnTimer = Int(self.timeRemaining/3600)
                    let newMinutes = intValue
                    let secondsLeftOnTimer = self.timeRemaining % 60
                    
                    self.timeRemaining = hoursLeftOnTimer * 3600 + newMinutes * 60 + secondsLeftOnTimer
                }
            }
        )
        
        let hoursRemaining = Binding(
            get: { String(self.timeRemaining/3600) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    let newHours = intValue
                    let minutesLeftOnTimer = Int(self.timeRemaining/60%60)
                    let secondsLeftOnTimer = self.timeRemaining % 60
                    
                    self.timeRemaining = newHours * 3600 + minutesLeftOnTimer * 60 + secondsLeftOnTimer
                }
            }
        )
        
        MenuBarExtra(String(format: "%02d:%02d:%02d", Int(self.timeRemaining/3600), Int(self.timeRemaining/60%60), self.timeRemaining % 60)) {
            VStack {
                
                LabeledContent {
                    TextField("Enter number", text: hoursRemaining)
                } label: {
                    Text("Hours")
                }
                
                LabeledContent {
                    TextField("Enter number", text: minutesRemaining)
                } label: {
                    Text("Minutes")
                }
                
                LabeledContent {
                    TextField("Enter number", text: secondsRemaining)
                } label: {
                    Text("Seconds")
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
