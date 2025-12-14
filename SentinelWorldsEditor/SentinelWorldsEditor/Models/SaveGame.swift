//
// SaveGame.swift
// Sentinel Worlds I: Future Magic Save Game Editor
//
// Copyright (C) 2025 Lee (BigDinosaur)
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
import Combine

// MARK: - Main Save Game Container

/// Root data model for a Sentinel Worlds save game
///
/// Uses ObservableObject to enable SwiftUI's automatic UI updates when data changes.
/// All nested objects also use ObservableObject for fine-grained reactivity.
class SaveGame: ObservableObject {
    @Published var party: Party
    @Published var ship: Ship
    @Published var crew: [CrewMember]

    /// Tracks whether there are unsaved changes
    @Published var hasUnsavedChanges: Bool = false

    /// URL of the currently loaded save file
    var fileURL: URL?

    init() {
        self.party = Party()
        self.ship = Ship()
        self.crew = (1...5).map { CrewMember(crewNumber: $0) }
    }
}

// MARK: - Party Data

/// Party-wide values (cash and light energy)
class Party {
    var cash: Int = 0
    var lightEnergy: Int = 0

    init(cash: Int = 0, lightEnergy: Int = 0) {
        self.cash = cash
        self.lightEnergy = lightEnergy
    }
}

// MARK: - Ship Data

/// Ship software levels
class Ship {
    var move: Int = 0
    var target: Int = 0
    var engine: Int = 0
    var laser: Int = 0

    init(move: Int = 0, target: Int = 0, engine: Int = 0, laser: Int = 0) {
        self.move = move
        self.target = target
        self.engine = engine
        self.laser = laser
    }
}

// MARK: - Crew Member Data

/// Data for a single crew member (5 crew members total)
class CrewMember: Identifiable {
    let id: Int  // Crew number (1-5)

    var name: String = ""
    var rank: Int = 0
    var hp: Int = 0
    var characteristics = Characteristics()
    var abilities = Abilities()
    var equipment = Equipment()

    init(crewNumber: Int) {
        self.id = crewNumber
    }
}

// MARK: - Characteristics (Stats)

/// Five core characteristics (stats) for a crew member
struct Characteristics {
    var strength: Int = 0
    var stamina: Int = 0
    var dexterity: Int = 0
    var comprehend: Int = 0
    var charisma: Int = 0
}

// MARK: - Abilities (Skills)

/// Twelve abilities (skills) for a crew member
struct Abilities {
    var contact: Int = 0
    var edged: Int = 0
    var projectile: Int = 0
    var blaster: Int = 0
    var tactics: Int = 0
    var recon: Int = 0
    var gunnery: Int = 0
    var atvRepair: Int = 0
    var mining: Int = 0
    var athletics: Int = 0
    var observation: Int = 0
    var bribery: Int = 0
}

// MARK: - Equipment

/// Equipment slots for a crew member
///
/// Equipment uses UInt8 item codes (see ItemConstants.swift for item definitions).
/// Empty slots are represented by 0xFF (ItemConstants.emptySlot).
///
/// **Implementation Note:**
/// Uses individual properties instead of arrays due to a malloc deallocation error
/// that occurs in the test environment when arrays (stored or computed) are used.
/// This is a workaround for what appears to be a Swift compiler/runtime issue.
struct Equipment {
    var armor: UInt8 = 0xFF
    var weapon: UInt8 = 0xFF

    // On-hand weapons (3 slots) - individual properties instead of array
    var onhandWeapon1: UInt8 = 0xFF
    var onhandWeapon2: UInt8 = 0xFF
    var onhandWeapon3: UInt8 = 0xFF

    // Inventory (8 slots) - individual properties instead of array
    var inventory1: UInt8 = 0xFF
    var inventory2: UInt8 = 0xFF
    var inventory3: UInt8 = 0xFF
    var inventory4: UInt8 = 0xFF
    var inventory5: UInt8 = 0xFF
    var inventory6: UInt8 = 0xFF
    var inventory7: UInt8 = 0xFF
    var inventory8: UInt8 = 0xFF
}
