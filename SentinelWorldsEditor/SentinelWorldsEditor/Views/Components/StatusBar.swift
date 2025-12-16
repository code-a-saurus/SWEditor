//
// StatusBar.swift
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

/// Status bar component that shows filename and unsaved changes indicator
struct StatusBar: View {
    let message: String
    let hasUnsavedChanges: Bool

    var body: some View {
        HStack {
            // Status message (filename or other info)
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()

            // Unsaved changes indicator
            if hasUnsavedChanges {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Unsaved changes")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(nsColor: .separatorColor)),
            alignment: .top
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        Text("Main Content Area")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))

        StatusBar(message: "gamea.fm", hasUnsavedChanges: false)
        StatusBar(message: "gamea.fm", hasUnsavedChanges: true)
    }
    .frame(width: 600, height: 400)
}
