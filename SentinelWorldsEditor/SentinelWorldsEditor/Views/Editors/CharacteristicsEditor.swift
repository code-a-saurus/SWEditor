// CharacteristicsEditor.swift
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

/// Editor for crew member characteristics
struct CharacteristicsEditor: View {
    let crew: CrewMember
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalCharacteristics: Characteristics? = nil
    var undoManager: UndoManager? = nil

    // Use @State to enable proper SwiftUI change detection
    @State private var strength: Int = 0
    @State private var stamina: Int = 0
    @State private var dexterity: Int = 0
    @State private var comprehend: Int = 0
    @State private var charisma: Int = 0

    // Focus state for each field to detect when editing completes
    @FocusState private var isStrengthFocused: Bool
    @FocusState private var isStaminaFocused: Bool
    @FocusState private var isDexterityFocused: Bool
    @FocusState private var isComprehendFocused: Bool
    @FocusState private var isCharismaFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(crew.name) - Characteristics")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                ValidatedNumberField(
                    label: "Strength",
                    value: $strength,
                    isFocused: $isStrengthFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: { oldValue, newValue in
                        crew.characteristics.strength = strength
                    },
                    originalValue: originalCharacteristics?.strength,
                    undoManager: undoManager
                )

                ValidatedNumberField(
                    label: "Stamina",
                    value: $stamina,
                    isFocused: $isStaminaFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: { oldValue, newValue in
                        crew.characteristics.stamina = stamina
                    },
                    originalValue: originalCharacteristics?.stamina,
                    undoManager: undoManager
                )

                ValidatedNumberField(
                    label: "Dexterity",
                    value: $dexterity,
                    isFocused: $isDexterityFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: { oldValue, newValue in
                        crew.characteristics.dexterity = dexterity
                    },
                    originalValue: originalCharacteristics?.dexterity,
                    undoManager: undoManager
                )

                ValidatedNumberField(
                    label: "Comprehend",
                    value: $comprehend,
                    isFocused: $isComprehendFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: { oldValue, newValue in
                        crew.characteristics.comprehend = comprehend
                    },
                    originalValue: originalCharacteristics?.comprehend,
                    undoManager: undoManager
                )

                ValidatedNumberField(
                    label: "Charisma",
                    value: $charisma,
                    isFocused: $isCharismaFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: { oldValue, newValue in
                        crew.characteristics.charisma = charisma
                    },
                    originalValue: originalCharacteristics?.charisma,
                    undoManager: undoManager
                )
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Initialize @State from model when view appears
            strength = crew.characteristics.strength
            stamina = crew.characteristics.stamina
            dexterity = crew.characteristics.dexterity
            comprehend = crew.characteristics.comprehend
            charisma = crew.characteristics.charisma
        }
        // Detect when each field loses focus, register undo, and mark as changed
        .onChange(of: isStrengthFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && crew.characteristics.strength != strength {
                let oldValue = crew.characteristics.strength
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.characteristics.strength = strength

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.characteristics.strength = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Strength")

                onChanged()
            }
        }
        .onChange(of: isStaminaFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && crew.characteristics.stamina != stamina {
                let oldValue = crew.characteristics.stamina
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.characteristics.stamina = stamina

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.characteristics.stamina = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Stamina")

                onChanged()
            }
        }
        .onChange(of: isDexterityFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && crew.characteristics.dexterity != dexterity {
                let oldValue = crew.characteristics.dexterity
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.characteristics.dexterity = dexterity

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.characteristics.dexterity = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Dexterity")

                onChanged()
            }
        }
        .onChange(of: isComprehendFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && crew.characteristics.comprehend != comprehend {
                let oldValue = crew.characteristics.comprehend
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.characteristics.comprehend = comprehend

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.characteristics.comprehend = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Comprehend")

                onChanged()
            }
        }
        .onChange(of: isCharismaFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && crew.characteristics.charisma != charisma {
                let oldValue = crew.characteristics.charisma
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.characteristics.charisma = charisma

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.characteristics.charisma = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Charisma")

                onChanged()
            }
        }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if this field isn't currently focused
            if !isStrengthFocused {
                strength = crew.characteristics.strength
            }
            if !isStaminaFocused {
                stamina = crew.characteristics.stamina
            }
            if !isDexterityFocused {
                dexterity = crew.characteristics.dexterity
            }
            if !isComprehendFocused {
                comprehend = crew.characteristics.comprehend
            }
            if !isCharismaFocused {
                charisma = crew.characteristics.charisma
            }
        }
    }
}
