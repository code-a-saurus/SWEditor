// PartyCashEditor.swift
// Sentinel Worlds Editor - Swift Port
//
// Copyright (C) 2025 Lee R.
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

import SwiftUI
import Combine

/// Editor for party cash
struct PartyCashEditor: View {
    let party: Party
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalCash: Int? = nil
    var undoManager: UndoManager? = nil

    @State private var cash: Int = 0
    @FocusState private var isCashFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Party Cash")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "Cash",
                value: $cash,
                isFocused: $isCashFocused,
                range: 0...SaveFileConstants.MaxValues.cash,
                onCommit: { oldValue, newValue in
                    party.cash = cash
                },
                originalValue: originalCash,
                undoManager: undoManager
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            cash = party.cash
        }
        .onChange(of: isCashFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && party.cash != cash {
                let oldValue = party.cash
                let targetParty = party
                let targetSaveGame = saveGame
                party.cash = cash

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetParty.cash = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Cash")

                onChanged()
            }
        }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if this field isn't currently focused
            if !isCashFocused {
                cash = party.cash
            }
        }
    }
}
