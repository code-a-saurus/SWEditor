//
// AppDelegate.swift
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

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var appState: AppState?

    /// Called when user tries to quit the application (Cmd+Q)
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let appState = appState else {
            return .terminateNow
        }

        // Check if there are unsaved changes
        if appState.saveGame.hasUnsavedChanges && !appState.shouldTerminateWithoutSaving {
            // Show alert on main thread
            DispatchQueue.main.async {
                self.showUnsavedChangesAlert()
            }
            return .terminateLater
        }

        return .terminateNow
    }

    /// Shows an alert asking user what to do with unsaved changes
    private func showUnsavedChangesAlert() {
        let alert = NSAlert()
        alert.messageText = "Unsaved Changes"
        alert.informativeText = "Do you want to save changes before quitting?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn: // Save
            handleSave()
        case .alertSecondButtonReturn: // Don't Save
            appState?.shouldTerminateWithoutSaving = true
            NSApplication.shared.reply(toApplicationShouldTerminate: true)
        default: // Cancel
            NSApplication.shared.reply(toApplicationShouldTerminate: false)
        }
    }

    /// Attempts to save the current file
    private func handleSave() {
        guard let appState = appState,
              let fileURL = appState.saveGame.fileURL else {
            // No file to save, just quit
            NSApplication.shared.reply(toApplicationShouldTerminate: true)
            return
        }

        do {
            try SaveFileService.save(appState.saveGame, to: fileURL)
            // Save successful, allow termination
            NSApplication.shared.reply(toApplicationShouldTerminate: true)
        } catch {
            // Save failed, show error and cancel termination
            DispatchQueue.main.async {
                let errorAlert = NSAlert()
                errorAlert.messageText = "Save Failed"
                errorAlert.informativeText = "Could not save file: \(error.localizedDescription)"
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "OK")
                errorAlert.runModal()
            }
            NSApplication.shared.reply(toApplicationShouldTerminate: false)
        }
    }
}
