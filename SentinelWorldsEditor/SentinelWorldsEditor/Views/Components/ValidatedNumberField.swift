//
// ValidatedNumberField.swift
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

/// A validated number input field with range checking and visual feedback
struct ValidatedNumberField: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let onChange: () -> Void

    private var isValid: Bool {
        range.contains(value)
    }

    var body: some View {
        HStack {
            Text(label + ":")
                .frame(width: 120, alignment: .leading)

            TextField("", value: $value, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                .border(isValid ? Color.clear : Color.red, width: 2)
                .onChange(of: value) { _ in
                    onChange()
                }

            if isValid {
                Text("(max: \(range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("(\(range.lowerBound)-\(range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ValidatedNumberField(
            label: "HP",
            value: .constant(100),
            range: 0...125,
            onChange: { print("Changed") }
        )

        ValidatedNumberField(
            label: "HP",
            value: .constant(200),  // Invalid - out of range
            range: 0...125,
            onChange: { print("Changed") }
        )

        ValidatedNumberField(
            label: "Cash",
            value: .constant(50000),
            range: 0...655359,
            onChange: { print("Changed") }
        )
    }
    .padding()
}
