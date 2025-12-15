// PartyLightEditor.swift
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

/// Editor for party light energy
struct PartyLightEditor: View {
    let party: Party
    let onChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Light Energy")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "Light Energy",
                value: Binding(
                    get: { party.lightEnergy },
                    set: { party.lightEnergy = $0 }
                ),
                range: 0...SaveFileConstants.MaxValues.lightEnergy,
                onChange: onChanged
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
