//
// ContentView.swift
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
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var saveGame = SaveGame()
    @State private var statusMessage = "No file loaded"
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""

    // Mark file as having unsaved changes
    private func markChanged() {
        saveGame.hasUnsavedChanges = true
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            if saveGame.fileURL == nil {
                welcomeView
            } else {
                dataDisplayView
            }

            // Status bar at bottom
            StatusBar(
                message: statusMessage,
                hasUnsavedChanges: saveGame.hasUnsavedChanges
            )
        }
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { showingFilePicker = true }) {
                    Label("Open File", systemImage: "folder")
                }
                .help("Open a save file (Cmd+O)")
                .keyboardShortcut("o", modifiers: .command)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "fm") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("Error Loading File", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Welcome View

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.gearshape")
                .font(.system(size: 72))
                .foregroundColor(.secondary)

            Text("Sentinel Worlds I: Future Magic")
                .font(.title)
                .fontWeight(.bold)

            Text("Save Game Editor")
                .font(.title2)
                .foregroundColor(.secondary)

            Divider()
                .frame(width: 300)
                .padding()

            Button(action: { showingFilePicker = true }) {
                Label("Open Save File", systemImage: "folder")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("Choose a save file (gameX.fm) to begin")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - Data Display View

    private var dataDisplayView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Party section
                GroupBox(label: Label("Party", systemImage: "person.3")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ValidatedNumberField(
                            label: "Cash",
                            value: $saveGame.party.cash,
                            range: 0...SaveFileConstants.MaxValues.cash,
                            onChange: markChanged
                        )

                        ValidatedNumberField(
                            label: "Light Energy",
                            value: $saveGame.party.lightEnergy,
                            range: 0...SaveFileConstants.MaxValues.lightEnergy,
                            onChange: markChanged
                        )
                    }
                    .padding(8)
                }

                // Ship section
                GroupBox(label: Label("Ship Software", systemImage: "airplane")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ValidatedNumberField(
                            label: "Move",
                            value: $saveGame.ship.move,
                            range: 0...SaveFileConstants.MaxValues.shipSoftware,
                            onChange: markChanged
                        )

                        ValidatedNumberField(
                            label: "Target",
                            value: $saveGame.ship.target,
                            range: 0...SaveFileConstants.MaxValues.shipSoftware,
                            onChange: markChanged
                        )

                        ValidatedNumberField(
                            label: "Engine",
                            value: $saveGame.ship.engine,
                            range: 0...SaveFileConstants.MaxValues.shipSoftware,
                            onChange: markChanged
                        )

                        ValidatedNumberField(
                            label: "Laser",
                            value: $saveGame.ship.laser,
                            range: 0...SaveFileConstants.MaxValues.shipSoftware,
                            onChange: markChanged
                        )
                    }
                    .padding(8)
                }

                // Crew members section
                ForEach(saveGame.crew) { crew in
                    GroupBox(label: Label("Crew \(crew.id): \(crew.name.isEmpty ? "(Unnamed)" : crew.name)", systemImage: "person.fill")) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Basic stats
                            HStack(spacing: 20) {
                                HStack {
                                    Text("HP:")
                                    Text("\(crew.hp)")
                                        .fontWeight(.semibold)
                                }
                                HStack {
                                    Text("Rank:")
                                    Text("\(crew.rank)")
                                        .fontWeight(.semibold)
                                }
                            }

                            Divider()

                            // Characteristics
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Characteristics")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    statRow("Strength:", crew.characteristics.strength)
                                    statRow("Stamina:", crew.characteristics.stamina)
                                    statRow("Dexterity:", crew.characteristics.dexterity)
                                    statRow("Comprehend:", crew.characteristics.comprehend)
                                    statRow("Charisma:", crew.characteristics.charisma)
                                }
                            }

                            Divider()

                            // Abilities
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Abilities")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    statRow("Contact:", crew.abilities.contact)
                                    statRow("Edged:", crew.abilities.edged)
                                    statRow("Projectile:", crew.abilities.projectile)
                                    statRow("Blaster:", crew.abilities.blaster)
                                    statRow("Tactics:", crew.abilities.tactics)
                                    statRow("Recon:", crew.abilities.recon)
                                    statRow("Gunnery:", crew.abilities.gunnery)
                                    statRow("ATV Repair:", crew.abilities.atvRepair)
                                    statRow("Mining:", crew.abilities.mining)
                                    statRow("Athletics:", crew.abilities.athletics)
                                    statRow("Observation:", crew.abilities.observation)
                                    statRow("Bribery:", crew.abilities.bribery)
                                }
                            }

                            Divider()

                            // Equipment
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Equipment")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                HStack {
                                    Text("Armor:")
                                        .frame(width: 100, alignment: .leading)
                                    Text(ItemConstants.itemName(for: crew.equipment.armor))
                                        .fontWeight(.semibold)
                                }
                                HStack {
                                    Text("Weapon:")
                                        .frame(width: 100, alignment: .leading)
                                    Text(ItemConstants.itemName(for: crew.equipment.weapon))
                                        .fontWeight(.semibold)
                                }

                                Text("On-hand Weapons:")
                                    .padding(.top, 4)
                                HStack {
                                    Text("1:")
                                        .frame(width: 20)
                                    Text(ItemConstants.itemName(for: crew.equipment.onhandWeapon1))
                                }
                                HStack {
                                    Text("2:")
                                        .frame(width: 20)
                                    Text(ItemConstants.itemName(for: crew.equipment.onhandWeapon2))
                                }
                                HStack {
                                    Text("3:")
                                        .frame(width: 20)
                                    Text(ItemConstants.itemName(for: crew.equipment.onhandWeapon3))
                                }

                                Text("Inventory:")
                                    .padding(.top, 4)
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                                    inventoryRow("1:", crew.equipment.inventory1)
                                    inventoryRow("2:", crew.equipment.inventory2)
                                    inventoryRow("3:", crew.equipment.inventory3)
                                    inventoryRow("4:", crew.equipment.inventory4)
                                    inventoryRow("5:", crew.equipment.inventory5)
                                    inventoryRow("6:", crew.equipment.inventory6)
                                    inventoryRow("7:", crew.equipment.inventory7)
                                    inventoryRow("8:", crew.equipment.inventory8)
                                }
                            }
                        }
                        .padding(8)
                    }
                }
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - Helper Views

    private func statRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
                .frame(width: 90, alignment: .leading)
            Text("\(value)")
                .fontWeight(.medium)
        }
    }

    private func inventoryRow(_ label: String, _ itemCode: UInt8) -> some View {
        HStack {
            Text(label)
                .frame(width: 20)
            Text(ItemConstants.itemName(for: itemCode))
                .font(.system(size: 12))
        }
    }

    // MARK: - File Handling

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            loadSaveFile(url: url)
        case .failure(let error):
            showError("Failed to select file: \(error.localizedDescription)")
        }
    }

    private func loadSaveFile(url: URL) {
        // Request access to security-scoped resource (required for sandboxed apps)
        guard url.startAccessingSecurityScopedResource() else {
            showError("Unable to access file. Please try again.")
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let loadedGame = try SaveFileService.load(from: url)

            // Copy loaded data to our @StateObject
            saveGame.party = loadedGame.party
            saveGame.ship = loadedGame.ship
            saveGame.crew = loadedGame.crew
            saveGame.fileURL = loadedGame.fileURL
            saveGame.hasUnsavedChanges = loadedGame.hasUnsavedChanges

            statusMessage = url.lastPathComponent
        } catch let error as SaveFileValidator.ValidationError {
            showError(error.localizedDescription)
        } catch {
            showError("Error loading file: \(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        statusMessage = "Error: \(message)"
    }
}

#Preview {
    ContentView()
}
