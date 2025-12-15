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
    @State private var showingSaveSuccess = false
    @State private var saveSuccessMessage = ""

    // Mark file as having unsaved changes
    private func markChanged() {
        saveGame.hasUnsavedChanges = true
    }

    // Save the current file
    private func handleSave() {
        guard let fileURL = saveGame.fileURL else { return }

        // Request access to security-scoped resource (required for sandboxed apps)
        guard fileURL.startAccessingSecurityScopedResource() else {
            showError("Unable to access file for saving. Please try again.")
            return
        }

        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }

        do {
            let backupCreated = try SaveFileService.save(saveGame, to: fileURL)
            statusMessage = "\(fileURL.lastPathComponent) - Saved"

            if backupCreated {
                saveSuccessMessage = "File saved successfully. A backup was created with .bak extension."
            } else {
                saveSuccessMessage = "File saved successfully.\n\nNote: Could not create backup file due to directory permissions. Consider manually backing up your save files."
            }
            showingSaveSuccess = true
        } catch let error as SaveFileValidator.ValidationError {
            showError(error.localizedDescription)
        } catch {
            showError("Error saving file: \(error.localizedDescription)")
        }
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

            ToolbarItem(placement: .primaryAction) {
                Button(action: handleSave) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .help("Save changes (Cmd+S)")
                .keyboardShortcut("s", modifiers: .command)
                .disabled(saveGame.fileURL == nil || !saveGame.hasUnsavedChanges)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "fm") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Saved Successfully", isPresented: $showingSaveSuccess) {
            Button("OK") { }
        } message: {
            Text(saveSuccessMessage)
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
                                ValidatedNumberField(
                                    label: "HP",
                                    value: $saveGame.crew[crew.id - 1].hp,
                                    range: 0...SaveFileConstants.MaxValues.hp,
                                    onChange: markChanged
                                )
                                ValidatedNumberField(
                                    label: "Rank",
                                    value: $saveGame.crew[crew.id - 1].rank,
                                    range: 0...254,
                                    onChange: markChanged
                                )
                            }

                            Divider()

                            // Characteristics
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Characteristics")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                VStack(alignment: .leading, spacing: 8) {
                                    ValidatedNumberField(
                                        label: "Strength",
                                        value: $saveGame.crew[crew.id - 1].characteristics.strength,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Stamina",
                                        value: $saveGame.crew[crew.id - 1].characteristics.stamina,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Dexterity",
                                        value: $saveGame.crew[crew.id - 1].characteristics.dexterity,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Comprehend",
                                        value: $saveGame.crew[crew.id - 1].characteristics.comprehend,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Charisma",
                                        value: $saveGame.crew[crew.id - 1].characteristics.charisma,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                }
                            }

                            Divider()

                            // Abilities
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Abilities")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                VStack(alignment: .leading, spacing: 8) {
                                    ValidatedNumberField(
                                        label: "Contact",
                                        value: $saveGame.crew[crew.id - 1].abilities.contact,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Edged",
                                        value: $saveGame.crew[crew.id - 1].abilities.edged,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Projectile",
                                        value: $saveGame.crew[crew.id - 1].abilities.projectile,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Blaster",
                                        value: $saveGame.crew[crew.id - 1].abilities.blaster,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Tactics",
                                        value: $saveGame.crew[crew.id - 1].abilities.tactics,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Recon",
                                        value: $saveGame.crew[crew.id - 1].abilities.recon,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Gunnery",
                                        value: $saveGame.crew[crew.id - 1].abilities.gunnery,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "ATV Repair",
                                        value: $saveGame.crew[crew.id - 1].abilities.atvRepair,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Mining",
                                        value: $saveGame.crew[crew.id - 1].abilities.mining,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Athletics",
                                        value: $saveGame.crew[crew.id - 1].abilities.athletics,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Observation",
                                        value: $saveGame.crew[crew.id - 1].abilities.observation,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
                                    ValidatedNumberField(
                                        label: "Bribery",
                                        value: $saveGame.crew[crew.id - 1].abilities.bribery,
                                        range: 0...SaveFileConstants.MaxValues.stat,
                                        onChange: markChanged
                                    )
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
