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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(crew.name) - Characteristics")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                ValidatedNumberField(
                    label: "Strength",
                    value: Binding(
                        get: { crew.characteristics.strength },
                        set: { crew.characteristics.strength = $0 }
                    ),
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onChange: onChanged
                )

                ValidatedNumberField(
                    label: "Stamina",
                    value: Binding(
                        get: { crew.characteristics.stamina },
                        set: { crew.characteristics.stamina = $0 }
                    ),
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onChange: onChanged
                )

                ValidatedNumberField(
                    label: "Dexterity",
                    value: Binding(
                        get: { crew.characteristics.dexterity },
                        set: { crew.characteristics.dexterity = $0 }
                    ),
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onChange: onChanged
                )

                ValidatedNumberField(
                    label: "Comprehend",
                    value: Binding(
                        get: { crew.characteristics.comprehend },
                        set: { crew.characteristics.comprehend = $0 }
                    ),
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onChange: onChanged
                )

                ValidatedNumberField(
                    label: "Charisma",
                    value: Binding(
                        get: { crew.characteristics.charisma },
                        set: { crew.characteristics.charisma = $0 }
                    ),
                    range: 0...SaveFileConstants.MaxValues.stat,
                    onChange: onChanged
                )
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
