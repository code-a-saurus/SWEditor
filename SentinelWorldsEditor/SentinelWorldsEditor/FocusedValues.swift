//
// FocusedValues.swift
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

/// Focused value for determining if save is available
struct FocusedCanSaveKey: FocusedValueKey {
    typealias Value = Bool
}

/// Focused value for determining if undo is available
struct FocusedCanUndoKey: FocusedValueKey {
    typealias Value = Bool
}

/// Focused value for determining if redo is available
struct FocusedCanRedoKey: FocusedValueKey {
    typealias Value = Bool
}

/// Focused value for the undo manager
struct FocusedUndoManagerKey: FocusedValueKey {
    typealias Value = UndoManager
}

extension FocusedValues {
    var canSave: Bool? {
        get { self[FocusedCanSaveKey.self] }
        set { self[FocusedCanSaveKey.self] = newValue }
    }

    var canUndo: Bool? {
        get { self[FocusedCanUndoKey.self] }
        set { self[FocusedCanUndoKey.self] = newValue }
    }

    var canRedo: Bool? {
        get { self[FocusedCanRedoKey.self] }
        set { self[FocusedCanRedoKey.self] = newValue }
    }

    var undoManager: UndoManager? {
        get { self[FocusedUndoManagerKey.self] }
        set { self[FocusedUndoManagerKey.self] = newValue }
    }
}
