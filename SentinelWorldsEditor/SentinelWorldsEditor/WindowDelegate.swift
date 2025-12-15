//
// WindowDelegate.swift
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

/// Window delegate to handle window close events and show unsaved changes indicator
class WindowDelegate: NSObject, NSWindowDelegate {
    var appState: AppState?

    /// Called when user tries to close the window
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let appState = appState else {
            return true
        }

        // Check if there are unsaved changes
        if appState.saveGame.hasUnsavedChanges && appState.saveGame.fileURL != nil {
            // Show alert on main thread
            DispatchQueue.main.async {
                self.showUnsavedChangesAlert(for: sender)
            }
            return false // Prevent close until user responds to alert
        }

        return true // Allow close
    }

    /// Shows an alert asking user what to do with unsaved changes
    private func showUnsavedChangesAlert(for window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = "Unsaved Changes"
        alert.informativeText = "Do you want to save changes before closing?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")

        alert.beginSheetModal(for: window) { response in
            switch response {
            case .alertFirstButtonReturn: // Save
                self.handleSaveAndClose(window: window)
            case .alertSecondButtonReturn: // Don't Save
                window.close()
            default: // Cancel
                break
            }
        }
    }

    /// Attempts to save the current file, then closes window
    private func handleSaveAndClose(window: NSWindow) {
        guard let appState = appState,
              let fileURL = appState.saveGame.fileURL else {
            // No file to save, just close
            window.close()
            return
        }

        do {
            try SaveFileService.save(appState.saveGame, to: fileURL)
            // Save successful, close window
            window.close()
        } catch {
            // Save failed, show error and don't close
            DispatchQueue.main.async {
                let errorAlert = NSAlert()
                errorAlert.messageText = "Save Failed"
                errorAlert.informativeText = "Could not save file: \(error.localizedDescription)"
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "OK")
                errorAlert.beginSheetModal(for: window)
            }
        }
    }
}
