// ShipSoftwareEditor.swift
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

/// Editor for all ship software values
struct ShipSoftwareEditor: View {
    let ship: Ship
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalMove: Int? = nil
    var originalTarget: Int? = nil
    var originalEngine: Int? = nil
    var originalLaser: Int? = nil
    var undoManager: UndoManager? = nil

    @State private var move: Int = 0
    @State private var target: Int = 0
    @State private var engine: Int = 0
    @State private var laser: Int = 0

    @FocusState private var isMoveFocused: Bool
    @FocusState private var isTargetFocused: Bool
    @FocusState private var isEngineFocused: Bool
    @FocusState private var isLaserFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ship Software")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "MOVE",
                value: $move,
                isFocused: $isMoveFocused,
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onCommit: { oldValue, newValue in
                    ship.move = move
                },
                originalValue: originalMove,
                undoManager: undoManager
            )

            ValidatedNumberField(
                label: "TARGET",
                value: $target,
                isFocused: $isTargetFocused,
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onCommit: { oldValue, newValue in
                    ship.target = target
                },
                originalValue: originalTarget,
                undoManager: undoManager
            )

            ValidatedNumberField(
                label: "ENGINE",
                value: $engine,
                isFocused: $isEngineFocused,
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onCommit: { oldValue, newValue in
                    ship.engine = engine
                },
                originalValue: originalEngine,
                undoManager: undoManager
            )

            ValidatedNumberField(
                label: "LASER",
                value: $laser,
                isFocused: $isLaserFocused,
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onCommit: { oldValue, newValue in
                    ship.laser = laser
                },
                originalValue: originalLaser,
                undoManager: undoManager
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            move = ship.move
            target = ship.target
            engine = ship.engine
            laser = ship.laser
        }
        .onChange(of: isMoveFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && ship.move != move {
                let oldValue = ship.move
                let targetShip = ship
                let targetSaveGame = saveGame
                ship.move = move

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetShip.move = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Ship MOVE")

                onChanged()
            }
        }
        .onChange(of: isTargetFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && ship.target != target {
                let oldValue = ship.target
                let targetShip = ship
                let targetSaveGame = saveGame
                ship.target = target

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetShip.target = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Ship TARGET")

                onChanged()
            }
        }
        .onChange(of: isEngineFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && ship.engine != engine {
                let oldValue = ship.engine
                let targetShip = ship
                let targetSaveGame = saveGame
                ship.engine = engine

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetShip.engine = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Ship ENGINE")

                onChanged()
            }
        }
        .onChange(of: isLaserFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused && ship.laser != laser {
                let oldValue = ship.laser
                let targetShip = ship
                let targetSaveGame = saveGame
                ship.laser = laser

                // Register undo action - use saveGame as target for truly global undo
                undoManager?.registerUndo(withTarget: saveGame) { _ in
                    targetSaveGame.objectWillChange.send()
                    targetShip.laser = oldValue
                    onChanged()
                }
                undoManager?.setActionName("Change Ship LASER")

                onChanged()
            }
        }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if this field isn't currently focused
            if !isMoveFocused {
                move = ship.move
            }
            if !isTargetFocused {
                target = ship.target
            }
            if !isEngineFocused {
                engine = ship.engine
            }
            if !isLaserFocused {
                laser = ship.laser
            }
        }
    }
}
