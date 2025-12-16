// PortraitPicker.swift
// SentinelWorldsEditor
//
// Reusable component for displaying and selecting crew member portraits
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

/// Reusable component for portrait display and selection
/// Shows the current portrait image and a dropdown picker for changing it
struct PortraitPicker: View {
    @Binding var selectedPortrait: UInt8
    let onChange: (_ oldValue: UInt8, _ newValue: UInt8) -> Void
    var originalPortrait: UInt8? = nil
    var undoManager: UndoManager? = nil

    var body: some View {
        VStack(spacing: 12) {
            // Portrait image display
            if let imageName = PortraitConstants.imageName(for: selectedPortrait) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .border(Color.gray, width: 1)
            } else {
                // Fallback for invalid portrait codes
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .border(Color.red, width: 2)
                    .overlay(
                        Text("Invalid\nPortrait")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    )
            }

            // Portrait picker dropdown
            Picker("Portrait", selection: $selectedPortrait) {
                ForEach(Array(PortraitConstants.validPortraits).sorted(), id: \.self) { code in
                    Text(PortraitConstants.displayName(for: code))
                        .tag(code)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 180)
            .onChange(of: selectedPortrait) { oldValue, newValue in
                if oldValue != newValue {
                    onChange(oldValue, newValue)
                }
            }

            // Display original portrait if different
            if let original = originalPortrait, selectedPortrait != original {
                HStack(spacing: 4) {
                    Text("was:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(PortraitConstants.nickname(for: original))
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
