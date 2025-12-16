// ItemPicker.swift
// SentinelWorldsEditor
//
// Reusable dropdown component for selecting equipment items
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

/// Reusable picker component for equipment items
/// Displays a dropdown menu with human-readable item names
/// Filters items based on valid item codes for the slot type
struct ItemPicker: View {
    let label: String
    @Binding var selectedItemCode: UInt8
    let validItems: [UInt8]
    let onChange: (_ oldValue: UInt8, _ newValue: UInt8) -> Void
    var originalItemCode: UInt8? = nil
    var undoManager: UndoManager? = nil

    var body: some View {
        HStack {
            Text(label + ":")
                .frame(width: 120, alignment: .leading)

            Picker("", selection: $selectedItemCode) {
                ForEach(validItems, id: \.self) { itemCode in
                    Text(ItemConstants.itemName(for: itemCode))
                        .tag(itemCode)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200)
            .onChange(of: selectedItemCode) { oldValue, newValue in
                if oldValue != newValue {
                    onChange(oldValue, newValue)
                }
            }

            // Display original value if it differs from current selection
            if let original = originalItemCode, selectedItemCode != original {
                Text("(was: \"\(ItemConstants.itemName(for: original))\")")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
