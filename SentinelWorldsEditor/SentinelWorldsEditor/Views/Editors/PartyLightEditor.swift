// PartyLightEditor.swift
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

/// Editor for party light energy
struct PartyLightEditor: View {
    let party: Party
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalLightEnergy: Int? = nil
    var undoManager: UndoManager? = nil

    @State private var lightEnergy: Int = 0
    @FocusState private var isLightEnergyFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Light Energy")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "Light Energy",
                value: $lightEnergy,
                isFocused: $isLightEnergyFocused,
                range: 0...SaveFileConstants.MaxValues.lightEnergy,
                onCommit: { oldValue, newValue in
                    party.lightEnergy = lightEnergy
                },
                originalValue: originalLightEnergy,
                undoManager: undoManager
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            lightEnergy = party.lightEnergy
        }
        .onChange(of: isLightEnergyFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && party.lightEnergy != lightEnergy {
                let oldValue = party.lightEnergy
                let targetParty = party
                let targetSaveGame = saveGame
                party.lightEnergy = lightEnergy

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetParty.lightEnergy = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Light Energy")

                onChanged()
            }
        }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if this field isn't currently focused
            if !isLightEnergyFocused {
                lightEnergy = party.lightEnergy
            }
        }
    }
}
