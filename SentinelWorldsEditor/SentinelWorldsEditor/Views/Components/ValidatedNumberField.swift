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
    var isFocused: FocusState<Bool>.Binding
    let range: ClosedRange<Int>
    let onCommit: () -> Void  // Renamed from onChange to clarify it's called on commit
    var originalValue: Int? = nil  // Optional original value for comparison

    private var isValid: Bool {
        range.contains(value)
    }

    /// Whether the value has been modified from its original
    private var isModified: Bool {
        guard let original = originalValue else { return false }
        return value != original
    }

    var body: some View {
        HStack {
            Text(label + ":")
                .frame(width: 120, alignment: .leading)

            TextField("", value: $value, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                .border(isValid ? Color.clear : Color.red, width: 2)
                .focused(isFocused)
                .onSubmit {
                    // Trigger when user presses Return
                    onCommit()
                }

            if isValid {
                // Show original value if modified
                if let original = originalValue, value != original {
                    Text("(was \(original))")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("(max: \(range.upperBound))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("(\(range.lowerBound)-\(range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var hp: Int = 100
        @State private var invalidHP: Int = 200
        @State private var cash: Int = 50000

        @FocusState private var isHPFocused: Bool
        @FocusState private var isInvalidHPFocused: Bool
        @FocusState private var isCashFocused: Bool

        var body: some View {
            VStack(spacing: 16) {
                ValidatedNumberField(
                    label: "HP",
                    value: $hp,
                    isFocused: $isHPFocused,
                    range: 0...125,
                    onCommit: { print("HP committed: \(hp)") }
                )

                ValidatedNumberField(
                    label: "HP (Invalid)",
                    value: $invalidHP,
                    isFocused: $isInvalidHPFocused,
                    range: 0...125,
                    onCommit: { print("Invalid HP committed: \(invalidHP)") }
                )

                ValidatedNumberField(
                    label: "Cash",
                    value: $cash,
                    isFocused: $isCashFocused,
                    range: 0...655359,
                    onCommit: { print("Cash committed: \(cash)") }
                )
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
