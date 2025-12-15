// CharacteristicsEditor.swift
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

/// Editor for crew member characteristics
struct CharacteristicsEditor: View {
    let crew: CrewMember
    let onChanged: () -> Void
    var originalCharacteristics: Characteristics? = nil

    // Use @State to enable proper SwiftUI change detection
    @State private var strength: Int = 0
    @State private var stamina: Int = 0
    @State private var dexterity: Int = 0
    @State private var comprehend: Int = 0
    @State private var charisma: Int = 0

    // Focus state for each field to detect when editing completes
    @FocusState private var isStrengthFocused: Bool
    @FocusState private var isStaminaFocused: Bool
    @FocusState private var isDexterityFocused: Bool
    @FocusState private var isComprehendFocused: Bool
    @FocusState private var isCharismaFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(crew.name) - Characteristics")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                ValidatedNumberField(
                    label: "Strength",
                    value: $strength,
                    isFocused: $isStrengthFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: {
                        crew.characteristics.strength = strength
                    },
                    originalValue: originalCharacteristics?.strength
                )

                ValidatedNumberField(
                    label: "Stamina",
                    value: $stamina,
                    isFocused: $isStaminaFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: {
                        crew.characteristics.stamina = stamina
                    },
                    originalValue: originalCharacteristics?.stamina
                )

                ValidatedNumberField(
                    label: "Dexterity",
                    value: $dexterity,
                    isFocused: $isDexterityFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: {
                        crew.characteristics.dexterity = dexterity
                    },
                    originalValue: originalCharacteristics?.dexterity
                )

                ValidatedNumberField(
                    label: "Comprehend",
                    value: $comprehend,
                    isFocused: $isComprehendFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: {
                        crew.characteristics.comprehend = comprehend
                    },
                    originalValue: originalCharacteristics?.comprehend
                )

                ValidatedNumberField(
                    label: "Charisma",
                    value: $charisma,
                    isFocused: $isCharismaFocused,
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onCommit: {
                        crew.characteristics.charisma = charisma
                    },
                    originalValue: originalCharacteristics?.charisma
                )
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Initialize @State from model when view appears
            strength = crew.characteristics.strength
            stamina = crew.characteristics.stamina
            dexterity = crew.characteristics.dexterity
            comprehend = crew.characteristics.comprehend
            charisma = crew.characteristics.charisma
        }
        // Detect when each field loses focus and mark as changed
        .onChange(of: isStrengthFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.characteristics.strength = strength
                onChanged()
            }
        }
        .onChange(of: isStaminaFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.characteristics.stamina = stamina
                onChanged()
            }
        }
        .onChange(of: isDexterityFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.characteristics.dexterity = dexterity
                onChanged()
            }
        }
        .onChange(of: isComprehendFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.characteristics.comprehend = comprehend
                onChanged()
            }
        }
        .onChange(of: isCharismaFocused) { wasFocused, isNowFocused in
            if wasFocused && !isNowFocused {
                crew.characteristics.charisma = charisma
                onChanged()
            }
        }
    }
}
