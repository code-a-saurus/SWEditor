// AbilitiesEditor.swift  
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

/// Editor for crew member abilities
struct AbilitiesEditor: View {
    let crew: CrewMember
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalAbilities: Abilities? = nil
    var undoManager: UndoManager? = nil

    @State private var contact: Int = 0
    @State private var edged: Int = 0
    @State private var projectile: Int = 0
    @State private var blaster: Int = 0
    @State private var tactics: Int = 0
    @State private var recon: Int = 0
    @State private var gunnery: Int = 0
    @State private var atvRepair: Int = 0
    @State private var mining: Int = 0
    @State private var athletics: Int = 0
    @State private var observation: Int = 0
    @State private var bribery: Int = 0

    @FocusState private var isContactFocused: Bool
    @FocusState private var isEdgedFocused: Bool
    @FocusState private var isProjectileFocused: Bool
    @FocusState private var isBlasterFocused: Bool
    @FocusState private var isTacticsFocused: Bool
    @FocusState private var isReconFocused: Bool
    @FocusState private var isGunneryFocused: Bool
    @FocusState private var isAtvRepairFocused: Bool
    @FocusState private var isMiningFocused: Bool
    @FocusState private var isAthleticsFocused: Bool
    @FocusState private var isObservationFocused: Bool
    @FocusState private var isBriberyFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(crew.name) - Abilities")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    makeField(label: "Contact", value: $contact, focused: $isContactFocused, original: originalAbilities?.contact)
                    makeField(label: "Edged", value: $edged, focused: $isEdgedFocused, original: originalAbilities?.edged)
                    makeField(label: "Projectile", value: $projectile, focused: $isProjectileFocused, original: originalAbilities?.projectile)
                    makeField(label: "Blaster", value: $blaster, focused: $isBlasterFocused, original: originalAbilities?.blaster)
                    makeField(label: "Tactics", value: $tactics, focused: $isTacticsFocused, original: originalAbilities?.tactics)
                    makeField(label: "Recon", value: $recon, focused: $isReconFocused, original: originalAbilities?.recon)
                    makeField(label: "Gunnery", value: $gunnery, focused: $isGunneryFocused, original: originalAbilities?.gunnery)
                    makeField(label: "ATV Repair", value: $atvRepair, focused: $isAtvRepairFocused, original: originalAbilities?.atvRepair)
                    makeField(label: "Mining", value: $mining, focused: $isMiningFocused, original: originalAbilities?.mining)
                    makeField(label: "Athletics", value: $athletics, focused: $isAthleticsFocused, original: originalAbilities?.athletics)
                    makeField(label: "Observation", value: $observation, focused: $isObservationFocused, original: originalAbilities?.observation)
                    makeField(label: "Bribery", value: $bribery, focused: $isBriberyFocused, original: originalAbilities?.bribery)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            contact = crew.abilities.contact; edged = crew.abilities.edged
            projectile = crew.abilities.projectile; blaster = crew.abilities.blaster
            tactics = crew.abilities.tactics; recon = crew.abilities.recon
            gunnery = crew.abilities.gunnery; atvRepair = crew.abilities.atvRepair
            mining = crew.abilities.mining; athletics = crew.abilities.athletics
            observation = crew.abilities.observation; bribery = crew.abilities.bribery
        }
        .onChange(of: isContactFocused) { w, n in if w && !n && crew.abilities.contact != contact { let old = crew.abilities.contact; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.contact = contact; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.contact = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Contact"); onChanged() } }
        .onChange(of: isEdgedFocused) { w, n in if w && !n && crew.abilities.edged != edged { let old = crew.abilities.edged; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.edged = edged; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.edged = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Edged"); onChanged() } }
        .onChange(of: isProjectileFocused) { w, n in if w && !n && crew.abilities.projectile != projectile { let old = crew.abilities.projectile; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.projectile = projectile; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.projectile = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Projectile"); onChanged() } }
        .onChange(of: isBlasterFocused) { w, n in if w && !n && crew.abilities.blaster != blaster { let old = crew.abilities.blaster; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.blaster = blaster; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.blaster = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Blaster"); onChanged() } }
        .onChange(of: isTacticsFocused) { w, n in if w && !n && crew.abilities.tactics != tactics { let old = crew.abilities.tactics; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.tactics = tactics; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.tactics = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Tactics"); onChanged() } }
        .onChange(of: isReconFocused) { w, n in if w && !n && crew.abilities.recon != recon { let old = crew.abilities.recon; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.recon = recon; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.recon = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Recon"); onChanged() } }
        .onChange(of: isGunneryFocused) { w, n in if w && !n && crew.abilities.gunnery != gunnery { let old = crew.abilities.gunnery; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.gunnery = gunnery; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.gunnery = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Gunnery"); onChanged() } }
        .onChange(of: isAtvRepairFocused) { w, n in if w && !n && crew.abilities.atvRepair != atvRepair { let old = crew.abilities.atvRepair; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.atvRepair = atvRepair; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.atvRepair = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) ATV Repair"); onChanged() } }
        .onChange(of: isMiningFocused) { w, n in if w && !n && crew.abilities.mining != mining { let old = crew.abilities.mining; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.mining = mining; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.mining = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Mining"); onChanged() } }
        .onChange(of: isAthleticsFocused) { w, n in if w && !n && crew.abilities.athletics != athletics { let old = crew.abilities.athletics; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.athletics = athletics; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.athletics = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Athletics"); onChanged() } }
        .onChange(of: isObservationFocused) { w, n in if w && !n && crew.abilities.observation != observation { let old = crew.abilities.observation; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.observation = observation; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.observation = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Observation"); onChanged() } }
        .onChange(of: isBriberyFocused) { w, n in if w && !n && crew.abilities.bribery != bribery { let old = crew.abilities.bribery; let targetCrew = crew; let targetSaveGame = saveGame; crew.abilities.bribery = bribery; undoManager?.registerUndo(withTarget: saveGame) { _ in targetSaveGame.objectWillChange.send(); targetCrew.abilities.bribery = old; onChanged() }; undoManager?.setActionName("Change \(crew.name) Bribery"); onChanged() } }
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            // Only update if the field isn't currently focused
            if !isContactFocused { contact = crew.abilities.contact }
            if !isEdgedFocused { edged = crew.abilities.edged }
            if !isProjectileFocused { projectile = crew.abilities.projectile }
            if !isBlasterFocused { blaster = crew.abilities.blaster }
            if !isTacticsFocused { tactics = crew.abilities.tactics }
            if !isReconFocused { recon = crew.abilities.recon }
            if !isGunneryFocused { gunnery = crew.abilities.gunnery }
            if !isAtvRepairFocused { atvRepair = crew.abilities.atvRepair }
            if !isMiningFocused { mining = crew.abilities.mining }
            if !isAthleticsFocused { athletics = crew.abilities.athletics }
            if !isObservationFocused { observation = crew.abilities.observation }
            if !isBriberyFocused { bribery = crew.abilities.bribery }
        }
    }

    private func makeField(label: String, value: Binding<Int>, focused: FocusState<Bool>.Binding, original: Int?) -> some View {
        ValidatedNumberField(
            label: label,
            value: value,
            isFocused: focused,
            range: 0...SaveFileConstants.MaxValues.stat,
            onCommit: { _,_ in },
            originalValue: original,
            undoManager: undoManager
        )
    }
}
