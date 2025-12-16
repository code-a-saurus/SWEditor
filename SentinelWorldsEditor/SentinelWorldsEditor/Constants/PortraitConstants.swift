//
// PortraitConstants.swift
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

import Foundation

/// Portrait definitions and mappings for crew members
///
/// The game has 8 available crew portraits stored as single-byte values (0x01-0x08).
/// Each portrait is assigned a nickname for easier identification in the UI.
struct PortraitConstants {

    // MARK: - Portrait Codes

    /// Valid portrait codes (hex values 0x01 through 0x08)
    static let validPortraits: Set<UInt8> = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]

    // MARK: - Portrait to Image Mapping

    /// Maps portrait hex codes to asset catalog image names
    ///
    /// Images are stored in Assets.xcassets under "CrewPortraits" folder as p01-p08
    static let portraitImageNames: [UInt8: String] = [
        0x01: "p01",
        0x02: "p02",
        0x03: "p03",
        0x04: "p04",
        0x05: "p05",
        0x06: "p06",
        0x07: "p07",
        0x08: "p08"
    ]

    // MARK: - Portrait Nicknames

    /// Human-readable nicknames for each portrait
    static let portraitNicknames: [UInt8: String] = [
        0x01: "Mike",
        0x02: "Bluehair",
        0x03: "Burke",
        0x04: "Roger",
        0x05: "Allison",
        0x06: "TJ",
        0x07: "Casey",
        0x08: "Glasses"
    ]

    // MARK: - Helper Functions

    /// Get the image name for a portrait code
    /// - Parameter code: Portrait hex code (0x01-0x08)
    /// - Returns: Asset catalog image name, or nil if invalid code
    static func imageName(for code: UInt8) -> String? {
        return portraitImageNames[code]
    }

    /// Get the nickname for a portrait code
    /// - Parameter code: Portrait hex code (0x01-0x08)
    /// - Returns: Portrait nickname, or "Unknown" if invalid code
    static func nickname(for code: UInt8) -> String {
        return portraitNicknames[code] ?? "Unknown"
    }

    /// Get a display string combining nickname and code
    /// - Parameter code: Portrait hex code (0x01-0x08)
    /// - Returns: Formatted string like "Mike (p01)" or "Unknown (0xFF)" for invalid codes
    static func displayName(for code: UInt8) -> String {
        if let imageName = portraitImageNames[code],
           let nickname = portraitNicknames[code] {
            return "\(nickname) (\(imageName))"
        } else {
            return String(format: "Unknown (0x%02X)", code)
        }
    }

    /// Check if a portrait code is valid
    /// - Parameter code: Portrait hex code to validate
    /// - Returns: True if code is in valid range (0x01-0x08)
    static func isValid(_ code: UInt8) -> Bool {
        return validPortraits.contains(code)
    }
}
