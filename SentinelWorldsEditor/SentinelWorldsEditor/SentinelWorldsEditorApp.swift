//
// SentinelWorldsEditorApp.swift
// Sentinel Worlds I: Future Magic Save Game Editor
//
// Copyright (C) 2025 Lee Hutchinson (lee@bigdinosaur.org)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

@main
struct SentinelWorldsEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Wire up the app delegate to access our app state
                    appDelegate.appState = appState
                }
        }
        .commands {
            // Remove "New" command (not applicable to save editor)
            CommandGroup(replacing: .newItem) { }

            // File menu commands
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    // Trigger save via notification
                    NotificationCenter.default.post(name: .saveRequested, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(appState.saveGame.fileURL == nil || !appState.saveGame.hasUnsavedChanges)
            }

            // Help menu with GPL license
            CommandGroup(after: .help) {
                Divider()
                Button("View GPL License") {
                    appState.showGPLLicense = true
                }
                Button("About Sentinel Worlds Editor") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
            }
        }
    }
}

// Notification name for save command
extension Notification.Name {
    static let saveRequested = Notification.Name("saveRequested")
}
