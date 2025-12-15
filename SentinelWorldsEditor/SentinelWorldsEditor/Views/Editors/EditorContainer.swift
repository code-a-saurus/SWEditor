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

    var body: some View {
        Group {
            if let nodeType = selectedNode {
                switch nodeType {
                // Party editors
                case .partyCash:
                    PartyCashEditor(
                        party: saveGame.party,
                        onChanged: onChanged,
                        originalCash: saveGame.originalValues?.partyCash
                    )

                case .partyLight:
                    PartyLightEditor(
                        party: saveGame.party,
                        onChanged: onChanged,
                        originalLightEnergy: saveGame.originalValues?.partyLightEnergy
                    )

                // Ship editors
                case .shipSoftware:
                    ShipSoftwareEditor(
                        ship: saveGame.ship,
                        onChanged: onChanged,
                        originalMove: saveGame.originalValues?.shipMove,
                        originalTarget: saveGame.originalValues?.shipTarget,
                        originalEngine: saveGame.originalValues?.shipEngine,
                        originalLaser: saveGame.originalValues?.shipLaser
                    )

                // Crew editors
                case .crewCharacteristics(let crewNumber):
                    CharacteristicsEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged,
                        originalCharacteristics: saveGame.originalValues?.crew[crewNumber - 1].characteristics
                    )

                case .crewAbilities(let crewNumber):
                    AbilitiesEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged,
                        originalAbilities: saveGame.originalValues?.crew[crewNumber - 1].abilities
                    )

                case .crewHP(let crewNumber):
                    HPEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged,
                        originalHP: saveGame.originalValues?.crew[crewNumber - 1].hp,
                        originalRank: saveGame.originalValues?.crew[crewNumber - 1].rank
                    )

                case .crewEquipment(let crewNumber):
                    EquipmentEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged,
                        originalEquipment: saveGame.originalValues?.crew[crewNumber - 1].equipment
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
