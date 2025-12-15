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
import AppKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var statusMessage = "No file loaded"
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSaveSuccess = false
    @State private var saveSuccessMessage = ""
    @State private var showingUnsavedChangesAlert = false
    @State private var pendingFileURL: URL? // Store URL to load after handling unsaved changes

    // Window management
    @State private var window: NSWindow?
    private let windowDelegate = WindowDelegate()

    // Tree navigation state
    @State private var treeNodes: [TreeNode] = []
    @State private var selectedNode: TreeNode.NodeType?

    // Computed property for convenience
    private var saveGame: SaveGame {
        appState.saveGame
    }

    // Mark file as having unsaved changes
    private func markChanged() {
        appState.saveGame.hasUnsavedChanges = true
    }

    // Computed property for window title
    private var windowTitle: String {
        if let fileURL = saveGame.fileURL {
            let filename = fileURL.lastPathComponent
            if saveGame.hasUnsavedChanges {
                return "● \(filename) - Sentinel Worlds Editor"
            } else {
                return "\(filename) - Sentinel Worlds Editor"
            }
        } else {
            return "Sentinel Worlds Editor"
        }
    }

    // Save the current file
    private func handleSave() {
        guard let fileURL = appState.saveGame.fileURL else { return }

        // NSOpenPanel provides read-write access automatically, no need for security-scoped resource
        do {
            try SaveFileService.save(appState.saveGame, to: fileURL)
            statusMessage = "\(fileURL.lastPathComponent) - Saved"
            saveSuccessMessage = "File saved successfully."
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
                // Navigation split view with tree sidebar
                NavigationSplitView {
                    // Left sidebar - Tree navigation
                    List(selection: $selectedNode) {
                        ForEach(treeNodes) { node in
                            treeNodeView(node: node)
                        }
                    }
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                    .listStyle(.sidebar)
                } detail: {
                    // Right detail - Editor area
                    EditorContainer(
                        saveGame: saveGame,
                        selectedNode: selectedNode,
                        onChanged: markChanged
                    )
                }
                .navigationTitle(windowTitle)
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
                Button(action: initiateOpenFile) {
                    Label("Open File", systemImage: "folder")
                }
                .help("Open a save file (Cmd+O)")
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: handleSave) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .help("Save changes (Cmd+S)")
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
        .sheet(isPresented: $appState.showGPLLicense) {
            GPLLicenseView()
        }
        .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
            Button("Save") {
                handleSaveBeforeOpen()
            }
            Button("Don't Save", role: .destructive) {
                handleDontSaveBeforeOpen()
            }
            Button("Cancel", role: .cancel) {
                pendingFileURL = nil
            }
        } message: {
            Text("Do you want to save changes before opening a new file?")
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveRequested)) { _ in
            handleSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openRequested)) { _ in
            initiateOpenFile()
        }
        .accessWindow(window: $window)
        .onAppear {
            // Set up window delegate
            windowDelegate.appState = appState
        }
        .onChange(of: window) { newWindow in
            // Configure window when it becomes available
            if let window = newWindow {
                window.delegate = windowDelegate
                window.isDocumentEdited = saveGame.hasUnsavedChanges
            }
        }
        .onChange(of: saveGame.hasUnsavedChanges) { hasChanges in
            // Update the window's edited state (shows dot in close button)
            window?.isDocumentEdited = hasChanges
        }
        .focusedSceneValue(\.canSave, saveGame.fileURL != nil && saveGame.hasUnsavedChanges)
    }

    // MARK: - Tree Navigation

    /// Recursively renders tree nodes with children
    private func treeNodeView(node: TreeNode) -> AnyView {
        if let children = node.children {
            return AnyView(
                DisclosureGroup {
                    ForEach(children) { child in
                        treeNodeView(node: child)
                    }
                } label: {
                    Label(node.title, systemImage: iconForNodeType(node.type))
                        .tag(node.type)
                }
            )
        } else {
            return AnyView(
                Label(node.title, systemImage: iconForNodeType(node.type))
                    .tag(node.type)
            )
        }
    }

    /// Returns appropriate SF Symbol icon for each node type
    private func iconForNodeType(_ type: TreeNode.NodeType) -> String {
        switch type {
        case .party, .partyCash, .partyLight:
            return "person.3"
        case .ship, .shipSoftware:
            return "airplane"
        case .crewRoot, .crewMember:
            return "person.fill"
        case .crewCharacteristics:
            return "chart.bar"
        case .crewAbilities:
            return "star"
        case .crewHP:
            return "heart.fill"
        case .crewEquipment:
            return "backpack"
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

            Button(action: initiateOpenFile) {
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


    // MARK: - File Handling

    /// Initiates the file open process, checking for unsaved changes first
    private func initiateOpenFile() {
        // Check if there are unsaved changes
        if saveGame.hasUnsavedChanges && saveGame.fileURL != nil {
            // Show alert - the actual open will happen after user responds
            pendingFileURL = nil // Will be set when user picks a file
            showOpenPanelWithUnsavedCheck()
        } else {
            // No unsaved changes, proceed directly to open panel
            showOpenPanel()
        }
    }

    /// Shows open panel, but will check for unsaved changes before loading
    private func showOpenPanelWithUnsavedCheck() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType(filenameExtension: "fm") ?? .data]
        panel.message = "Choose a save file to edit"
        panel.prompt = "Open"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Store the URL and show unsaved changes alert
                self.pendingFileURL = url
                self.showingUnsavedChangesAlert = true
            }
        }
    }

    /// Handles "Save" choice in unsaved changes alert
    private func handleSaveBeforeOpen() {
        guard let fileURL = saveGame.fileURL else {
            // No file to save, just proceed to open
            handleDontSaveBeforeOpen()
            return
        }

        do {
            try SaveFileService.save(saveGame, to: fileURL)
            // Save successful, now open the pending file
            if let pendingURL = pendingFileURL {
                loadSaveFileDirectly(url: pendingURL)
            }
        } catch {
            showError("Failed to save: \(error.localizedDescription)")
        }
        pendingFileURL = nil
    }

    /// Handles "Don't Save" choice in unsaved changes alert
    private func handleDontSaveBeforeOpen() {
        if let pendingURL = pendingFileURL {
            loadSaveFileDirectly(url: pendingURL)
        }
        pendingFileURL = nil
    }

    private func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType(filenameExtension: "fm") ?? .data]
        panel.message = "Choose a save file to edit"
        panel.prompt = "Open"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                loadSaveFileDirectly(url: url)
            }
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            loadSaveFileDirectly(url: url)
        case .failure(let error):
            showError("Failed to select file: \(error.localizedDescription)")
        }
    }

    /// Loads a save file without checking for unsaved changes (internal use)
    private func loadSaveFileDirectly(url: URL) {
        // NSOpenPanel provides read-write access automatically, no need for security-scoped resource
        do {
            let loadedGame = try SaveFileService.load(from: url)

            // Copy loaded data to our shared app state
            appState.saveGame.party = loadedGame.party
            appState.saveGame.ship = loadedGame.ship
            appState.saveGame.crew = loadedGame.crew
            appState.saveGame.fileURL = loadedGame.fileURL
            appState.saveGame.hasUnsavedChanges = loadedGame.hasUnsavedChanges

            // Build navigation tree
            treeNodes = TreeNode.buildTree(from: appState.saveGame)

            // Select first editable node by default (Party Cash)
            selectedNode = .partyCash

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
        .environmentObject(AppState())
}
