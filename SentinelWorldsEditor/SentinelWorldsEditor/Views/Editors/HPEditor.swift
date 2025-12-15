// HPEditor.swift
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

/// Editor for crew member hit points and rank
struct HPEditor: View {
    let crew: CrewMember
    let onChanged: () -> Void
    var originalHP: Int? = nil
    var originalRank: Int? = nil

    // Use @State to enable proper SwiftUI change detection
    @State private var hp: Int = 0
    @State private var rank: Int = 0

    // Focus state for each field to detect when editing completes
    @FocusState private var isHPFocused: Bool
    @FocusState private var isRankFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(crew.name) - Hit Points & Rank")
                .font(.title2)
                .fontWeight(.bold)

            ValidatedNumberField(
                label: "Hit Points",
                value: $hp,
                isFocused: $isHPFocused,
                range: 0...SaveFileConstants.MaxValues.hp,
                onCommit: {
                    // Sync to model (but don't mark as changed yet)
                    crew.hp = hp
                },
                originalValue: originalHP
            )

            ValidatedNumberField(
                label: "Rank",
                value: $rank,
                isFocused: $isRankFocused,
                range: 0...SaveFileConstants.MaxValues.rank,
                onCommit: {
                    // Sync to model (but don't mark as changed yet)
                    crew.rank = rank
                },
                originalValue: originalRank
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // Initialize @State from model when view appears
            hp = crew.hp
            rank = crew.rank
        }
        .onChange(of: isHPFocused) { wasFocused, isNowFocused in
            // When HP field loses focus, mark as changed
            if wasFocused && !isNowFocused {
                crew.hp = hp
                onChanged()
            }
        }
        .onChange(of: isRankFocused) { wasFocused, isNowFocused in
            // When Rank field loses focus, mark as changed
            if wasFocused && !isNowFocused {
                crew.rank = rank
                onChanged()
            }
        }
    }
}
