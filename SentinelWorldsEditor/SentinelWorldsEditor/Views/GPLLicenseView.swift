//
// GPLLicenseView.swift
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

struct GPLLicenseView: View {
    @Environment(\.dismiss) var dismiss

    private let licenseText = """
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

Full license text:
https://www.gnu.org/licenses/gpl-3.0.html

Copyright (C) 2025 Lee Hutchinson (lee@bigdinosaur.org)
"""

    var body: some View {
        VStack(spacing: 20) {
            Text("License Information")
                .font(.title)
                .fontWeight(.bold)

            ScrollView {
                Text(licenseText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .frame(maxHeight: 300)

            Link("View Full GPL-3.0 License", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!)
                .font(.headline)

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 500, height: 450)
    }
}

#Preview {
    GPLLicenseView()
}
