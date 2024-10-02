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
    @AppStorage("timeRemaining") var timeRemaining: Int = 60 // Timer duration in seconds
    @State private var running: Bool = false;
    
    @State var hoveringHours = false
    @State var hoveringMinutes = false
    @State var hoveringSeconds = false
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        
        let secondsRemaining = Binding(
            get: { String(self.timeRemaining%60) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    
                    let hoursLeftOnTimer = Int(self.timeRemaining/3600)
                    let minutesLeftOnTimer = Int(self.timeRemaining/60%60)
                    let newSeconds = max(0, min(intValue, 1024))
                    self.timeRemaining = hoursLeftOnTimer * 3600 + minutesLeftOnTimer * 60 + newSeconds
                }
            }
        )
        
        let minutesRemaining = Binding(
            get: { String(self.timeRemaining/60%60) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    let hoursLeftOnTimer = Int(self.timeRemaining/3600)
                    let newMinutes = max(0, min(intValue, 1024))
                    let secondsLeftOnTimer = self.timeRemaining % 60
                    
                    self.timeRemaining = hoursLeftOnTimer * 3600 + newMinutes * 60 + secondsLeftOnTimer
                }
            }
        )
        
        let hoursRemaining = Binding(
            get: { String(self.timeRemaining/3600) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    let newHours = max(0, min(intValue, 1024))
                    let minutesLeftOnTimer = Int(self.timeRemaining/60%60)
                    let secondsLeftOnTimer = self.timeRemaining % 60
                    
                    self.timeRemaining = newHours * 3600 + minutesLeftOnTimer * 60 + secondsLeftOnTimer
                }
            }
        )
        
        MenuBarExtra( Int(self.timeRemaining/3600) == 0 ? String(format: "%02d:%02d", Int(self.timeRemaining/60%60), self.timeRemaining % 60) : String(format: "%02d:%02d:%02d", Int(self.timeRemaining/3600), Int(self.timeRemaining/60%60), self.timeRemaining % 60)) {
            VStack {
                HStack {
                    TextField("hrs", text: hoursRemaining)
                        .onHover { hover in
                            hoveringHours = hover
                        }
                    Text(":")
                    TextField("min", text: minutesRemaining)
                        .onHover { hover in
                            hoveringMinutes = hover
                        }
                    Text(":")
                    TextField("sec", text: secondsRemaining)
                        .onHover { hover in
                            hoveringSeconds = hover
                        }
                }
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                
                
                Divider()
                HStack {
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }.keyboardShortcut("q")
                    Spacer()
                    Button(running ? "Pause" : "Start") {
                        running.toggle();
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
            .onAppear(perform:{
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) {event in
                    if (hoveringHours) {
                        hoursRemaining.wrappedValue = String(self.timeRemaining/3600 + Int(event.deltaY))
                    }
                    if (hoveringMinutes) {
                        minutesRemaining.wrappedValue = String(self.timeRemaining/60%60 + Int(event.deltaY))
                    }
                    if (hoveringSeconds) {
                        secondsRemaining.wrappedValue = String(self.timeRemaining%60 + Int(event.deltaY))
                    }
                    
                    return event
                }
            })
        }.menuBarExtraStyle(.window)
    }
    
}
