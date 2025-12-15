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

/// Editor for crew member abilities
struct AbilitiesEditor: View {
    let crew: CrewMember
    let onChanged: () -> Void
    var originalAbilities: Abilities? = nil

    // Use @State to enable proper SwiftUI change detection
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

    // Focus state for each field to detect when editing completes
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
                    ValidatedNumberField(
                        label: "Contact",
                        value: $contact,
                        isFocused: $isContactFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.contact = contact
                        },
                        originalValue: originalAbilities?.contact
                    )

                    ValidatedNumberField(
                        label: "Edged",
                        value: $edged,
                        isFocused: $isEdgedFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.edged = edged
                            
                        },
                        originalValue: originalAbilities?.edged
                    )

                    ValidatedNumberField(
                        label: "Projectile",
                        value: $projectile,
                        isFocused: $isProjectileFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.projectile = projectile
                            
                        },
                        originalValue: originalAbilities?.projectile
                    )

                    ValidatedNumberField(
                        label: "Blaster",
                        value: $blaster,
                        isFocused: $isBlasterFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.blaster = blaster
                            
                        },
                        originalValue: originalAbilities?.blaster
                    )

                    ValidatedNumberField(
                        label: "Tactics",
                        value: $tactics,
                        isFocused: $isTacticsFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.tactics = tactics
                            
                        },
                        originalValue: originalAbilities?.tactics
                    )

                    ValidatedNumberField(
                        label: "Recon",
                        value: $recon,
                        isFocused: $isReconFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.recon = recon
                            
                        },
                        originalValue: originalAbilities?.recon
                    )

                    ValidatedNumberField(
                        label: "Gunnery",
                        value: $gunnery,
                        isFocused: $isGunneryFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.gunnery = gunnery
                            
                        },
                        originalValue: originalAbilities?.gunnery
                    )

                    ValidatedNumberField(
                        label: "ATV Repair",
                        value: $atvRepair,
                        isFocused: $isAtvRepairFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.atvRepair = atvRepair
                            onChanged()
                        },
                        originalValue: originalAbilities?.atvRepair
                    )

                    ValidatedNumberField(
                        label: "Mining",
                        value: $mining,
                        isFocused: $isMiningFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.mining = mining
                            
                        },
                        originalValue: originalAbilities?.mining
                    )

                    ValidatedNumberField(
                        label: "Athletics",
                        value: $athletics,
                        isFocused: $isAthleticsFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.athletics = athletics
                            
                        },
                        originalValue: originalAbilities?.athletics
                    )

                    ValidatedNumberField(
                        label: "Observation",
                        value: $observation,
                        isFocused: $isObservationFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.observation = observation
                            
                        },
                        originalValue: originalAbilities?.observation
                    )

                    ValidatedNumberField(
                        label: "Bribery",
                        value: $bribery,
                        isFocused: $isBriberyFocused,
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onCommit: {
                            crew.abilities.bribery = bribery
                            
                        },
                        originalValue: originalAbilities?.bribery
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Initialize @State from model when view appears
            contact = crew.abilities.contact
            edged = crew.abilities.edged
            projectile = crew.abilities.projectile
            blaster = crew.abilities.blaster
            tactics = crew.abilities.tactics
            recon = crew.abilities.recon
            gunnery = crew.abilities.gunnery
            atvRepair = crew.abilities.atvRepair
            mining = crew.abilities.mining
            athletics = crew.abilities.athletics
            observation = crew.abilities.observation
            bribery = crew.abilities.bribery
        }
        // Detect when each field loses focus and mark as changed
        .onChange(of: isContactFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.contact = contact
                onChanged()
            }
        }
        .onChange(of: isEdgedFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.edged = edged
                onChanged()
            }
        }
        .onChange(of: isProjectileFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.projectile = projectile
                onChanged()
            }
        }
        .onChange(of: isBlasterFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.blaster = blaster
                onChanged()
            }
        }
        .onChange(of: isTacticsFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.tactics = tactics
                onChanged()
            }
        }
        .onChange(of: isReconFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.recon = recon
                onChanged()
            }
        }
        .onChange(of: isGunneryFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.gunnery = gunnery
                onChanged()
            }
        }
        .onChange(of: isAtvRepairFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.atvRepair = atvRepair
                onChanged()
            }
        }
        .onChange(of: isMiningFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.mining = mining
                onChanged()
            }
        }
        .onChange(of: isAthleticsFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.athletics = athletics
                onChanged()
            }
        }
        .onChange(of: isObservationFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.observation = observation
                onChanged()
            }
        }
        .onChange(of: isBriberyFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.abilities.bribery = bribery
                onChanged()
            }
        }
    }
}
