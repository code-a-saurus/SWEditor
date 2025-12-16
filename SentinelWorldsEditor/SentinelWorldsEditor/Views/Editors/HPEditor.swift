// HPEditor.swift
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

/// Editor for crew member hit points and rank
struct HPEditor: View {
    let crew: CrewMember
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalHP: Int? = nil
    var originalRank: Int? = nil
    var originalPortrait: UInt8? = nil
    var undoManager: UndoManager? = nil

    // Use @State to enable proper SwiftUI change detection
    @State private var hp: Int = 0
    @State private var rank: Int = 0
    @State private var portrait: UInt8 = 0x01

    // Focus state for each field to detect when editing completes
    @FocusState private var isHPFocused: Bool
    @FocusState private var isRankFocused: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 40) {
            // Left side: HP and Rank fields
            VStack(alignment: .leading, spacing: 20) {
                Text("\(crew.name) - Hit Points & Rank")
                    .font(.title2)
                    .fontWeight(.bold)

                ValidatedNumberField(
                    label: "Hit Points",
                    value: $hp,
                    isFocused: $isHPFocused,
                    range: 0...SaveFileConstants.MaxValues.hp,
                    onCommit: { oldValue, newValue in
                        // Sync to model (but don't mark as changed yet)
                        crew.hp = hp
                    },
                    originalValue: originalHP,
                    undoManager: undoManager
                )

                ValidatedNumberField(
                    label: "Rank",
                    value: $rank,
                    isFocused: $isRankFocused,
                    range: 0...SaveFileConstants.MaxValues.rank,
                    onCommit: { oldValue, newValue in
                        // Sync to model (but don't mark as changed yet)
                        crew.rank = rank
                    },
                    originalValue: originalRank,
                    undoManager: undoManager
                )

                Spacer()
            }

            // Right side: Portrait display and picker
            VStack(alignment: .trailing) {
                PortraitPicker(
                    selectedPortrait: $portrait,
                    onChange: { oldValue, newValue in
                        // Portrait change will be handled in onChange modifier
                    },
                    originalPortrait: originalPortrait,
                    undoManager: undoManager
                )
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Initialize @State from model when view appears
            hp = crew.hp
            rank = crew.rank
            portrait = crew.portrait
        }
        .onChange(of: isHPFocused) { wasFocused, isNowFocused in
            // When HP field loses focus, register undo and mark as changed
            if wasFocused && !isNowFocused && crew.hp != hp {
                let oldValue = crew.hp
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.hp = hp

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.hp = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) HP")

                onChanged()
            }
        }
        .onChange(of: isRankFocused) { wasFocused, isNowFocused in
            // When Rank field loses focus, register undo and mark as changed
            if wasFocused && !isNowFocused && crew.rank != rank {
                let oldValue = crew.rank
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.rank = rank

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.rank = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Rank")

                onChanged()
            }
        }
        .onChange(of: portrait) { oldValue, newValue in
            // When portrait changes, register undo and mark as changed
            if oldValue != newValue && crew.portrait != newValue {
                let targetCrew = crew
                let targetSaveGame = saveGame
                crew.portrait = newValue

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetCrew.portrait = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change \(crew.name) Portrait")

                onChanged()
            }
        }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if this field isn't currently focused
            if !isHPFocused {
                hp = crew.hp
            }
            if !isRankFocused {
                rank = crew.rank
            }
            // Portrait picker doesn't have focus, so always update
            portrait = crew.portrait
        }
    }
}
