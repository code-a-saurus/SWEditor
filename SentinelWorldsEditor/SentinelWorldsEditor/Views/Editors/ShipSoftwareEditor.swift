// ShipSoftwareEditor.swift
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

/// Editor for all ship software values
struct ShipSoftwareEditor: View {
    let ship: Ship
    let onChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ship Software")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "MOVE",
                value: Binding(
                    get: { ship.move },
                    set: { ship.move = $0 }
                ),
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onChange: onChanged
            )

            ValidatedNumberField(
                label: "TARGET",
                value: Binding(
                    get: { ship.target },
                    set: { ship.target = $0 }
                ),
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onChange: onChanged
            )

            ValidatedNumberField(
                label: "ENGINE",
                value: Binding(
                    get: { ship.engine },
                    set: { ship.engine = $0 }
                ),
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onChange: onChanged
            )

            ValidatedNumberField(
                label: "LASER",
                value: Binding(
                    get: { ship.laser },
                    set: { ship.laser = $0 }
                ),
                range: 0...SaveFileConstants.MaxValues.shipSoftware,
                onChange: onChanged
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
