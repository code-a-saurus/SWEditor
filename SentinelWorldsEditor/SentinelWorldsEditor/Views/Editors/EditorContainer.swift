// EditorContainer.swift
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

/// Routes navigation tree selections to the appropriate editor view
struct EditorContainer: View {
    @ObservedObject var saveGame: SaveGame
    let selectedNode: TreeNode.NodeType?
    let onChanged: () -> Void
    var undoManager: UndoManager? = nil

    var body: some View {
        Group {
            if let nodeType = selectedNode {
                switch nodeType {
                // Party editors
                case .partyCash:
                    PartyCashEditor(
                        party: saveGame.party,
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalCash: saveGame.originalValues?.partyCash,
                        undoManager: undoManager
                    )

                case .partyLight:
                    PartyLightEditor(
                        party: saveGame.party,
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalLightEnergy: saveGame.originalValues?.partyLightEnergy,
                        undoManager: undoManager
                    )

                // Ship editors
                case .shipSoftware:
                    ShipSoftwareEditor(
                        ship: saveGame.ship,
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalMove: saveGame.originalValues?.shipMove,
                        originalTarget: saveGame.originalValues?.shipTarget,
                        originalEngine: saveGame.originalValues?.shipEngine,
                        originalLaser: saveGame.originalValues?.shipLaser,
                        undoManager: undoManager
                    )

                // Crew editors
                case .crewCharacteristics(let crewNumber):
                    CharacteristicsEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalCharacteristics: saveGame.originalValues?.crew[crewNumber - 1].characteristics,
                        undoManager: undoManager
                    )

                case .crewAbilities(let crewNumber):
                    AbilitiesEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalAbilities: saveGame.originalValues?.crew[crewNumber - 1].abilities,
                        undoManager: undoManager
                    )

                case .crewHP(let crewNumber):
                    HPEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalHP: saveGame.originalValues?.crew[crewNumber - 1].hp,
                        originalRank: saveGame.originalValues?.crew[crewNumber - 1].rank,
                        undoManager: undoManager
                    )
                    .id("hp-\(crewNumber)")

                case .crewEquipment(let crewNumber):
                    EquipmentEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        saveGame: saveGame,
                        onChanged: onChanged,
                        originalEquipment: saveGame.originalValues?.crew[crewNumber - 1].equipment,
                        undoManager: undoManager
                    )

                // Parent nodes (no direct editor)
                case .party, .ship, .crewRoot, .crewMember:
                    placeholderView(title: "Select a specific item",
                                  message: "Choose a sub-item from the tree to edit")
                }
            } else {
                placeholderView(title: "No Selection",
                              message: "Select an item from the tree to begin editing")
            }
        }
    }

    /// Placeholder view for nodes without editors
    private func placeholderView(title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
