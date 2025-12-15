//
// AppState.swift
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
import Combine

/// Shared application state accessible from both ContentView and AppDelegate
class AppState: ObservableObject {
    @Published var saveGame: SaveGame = SaveGame()
    @Published var showGPLLicense = false

    /// Flag to bypass the unsaved changes check (used when user chooses "Don't Save")
    var shouldTerminateWithoutSaving = false

    /// Computed property to determine if Save menu item should be enabled
    /// This property is observed by menu commands to enable/disable the Save button
    var canSave: Bool {
        saveGame.fileURL != nil && saveGame.hasUnsavedChanges
    }
}
