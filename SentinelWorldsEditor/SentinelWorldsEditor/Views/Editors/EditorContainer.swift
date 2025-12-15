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
                    PartyCashEditor(party: saveGame.party, onChanged: onChanged)

                case .partyLight:
                    PartyLightEditor(party: saveGame.party, onChanged: onChanged)

                // Ship editors
                case .shipSoftware:
                    ShipSoftwareEditor(ship: saveGame.ship, onChanged: onChanged)

                // Crew editors
                case .crewCharacteristics(let crewNumber):
                    CharacteristicsEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged
                    )

                case .crewAbilities(let crewNumber):
                    AbilitiesEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged
                    )

                case .crewHP(let crewNumber):
                    HPEditor(
                        crew: saveGame.crew[crewNumber - 1],
                        onChanged: onChanged
                    )

                case .crewEquipment(let crewNumber):
                    placeholderView(title: "Equipment Editor",
                                  message: "Equipment editing will be added in Phase 6")

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
