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
class Party: ObservableObject {
    @Published var cash: Int = 0
    @Published var lightEnergy: Int = 0

    init(cash: Int = 0, lightEnergy: Int = 0) {
        self.cash = cash
        self.lightEnergy = lightEnergy
    }
}

// MARK: - Ship Data

/// Ship software levels
class Ship: ObservableObject {
    @Published var move: Int = 0
    @Published var target: Int = 0
    @Published var engine: Int = 0
    @Published var laser: Int = 0

    init(move: Int = 0, target: Int = 0, engine: Int = 0, laser: Int = 0) {
        self.move = move
        self.target = target
        self.engine = engine
        self.laser = laser
    }
}

// MARK: - Crew Member Data

/// Data for a single crew member (5 crew members total)
class CrewMember: ObservableObject, Identifiable {
    let id: Int  // Crew number (1-5)

    @Published var name: String
    @Published var rank: Int
    @Published var hp: Int
    @Published var characteristics: Characteristics
    @Published var abilities: Abilities
    @Published var equipment: Equipment

    init(crewNumber: Int) {
        self.id = crewNumber
        self.name = ""
        self.rank = 0
        self.hp = 0
        self.characteristics = Characteristics()
        self.abilities = Abilities()
        self.equipment = Equipment()
    }
}

// MARK: - Characteristics (Stats)

/// Five core characteristics (stats) for a crew member
class Characteristics: ObservableObject {
    @Published var strength: Int = 0
    @Published var stamina: Int = 0
    @Published var dexterity: Int = 0
    @Published var comprehend: Int = 0
    @Published var charisma: Int = 0

    init(strength: Int = 0, stamina: Int = 0, dexterity: Int = 0,
         comprehend: Int = 0, charisma: Int = 0) {
        self.strength = strength
        self.stamina = stamina
        self.dexterity = dexterity
        self.comprehend = comprehend
        self.charisma = charisma
    }
}

// MARK: - Abilities (Skills)

/// Twelve abilities (skills) for a crew member
class Abilities: ObservableObject {
    @Published var contact: Int = 0
    @Published var edged: Int = 0
    @Published var projectile: Int = 0
    @Published var blaster: Int = 0
    @Published var tactics: Int = 0
    @Published var recon: Int = 0
    @Published var gunnery: Int = 0
    @Published var atvRepair: Int = 0
    @Published var mining: Int = 0
    @Published var athletics: Int = 0
    @Published var observation: Int = 0
    @Published var bribery: Int = 0

    init(contact: Int = 0, edged: Int = 0, projectile: Int = 0, blaster: Int = 0,
         tactics: Int = 0, recon: Int = 0, gunnery: Int = 0, atvRepair: Int = 0,
         mining: Int = 0, athletics: Int = 0, observation: Int = 0, bribery: Int = 0) {
        self.contact = contact
        self.edged = edged
        self.projectile = projectile
        self.blaster = blaster
        self.tactics = tactics
        self.recon = recon
        self.gunnery = gunnery
        self.atvRepair = atvRepair
        self.mining = mining
        self.athletics = athletics
        self.observation = observation
        self.bribery = bribery
    }
}

// MARK: - Equipment

/// Equipment slots for a crew member
///
/// Equipment uses UInt8 item codes (see ItemConstants.swift for item definitions).
/// Empty slots are represented by 0xFF (ItemConstants.emptySlot).
class Equipment: ObservableObject {
    /// Currently equipped armor (1 slot)
    @Published var armor: UInt8

    /// Currently equipped weapon (1 slot)
    @Published var weapon: UInt8

    /// On-hand weapons (3 slots) - quick-access weapon slots
    @Published var onhandWeapons: [UInt8]

    /// General inventory (8 slots)
    @Published var inventory: [UInt8]

    init() {
        // Initialize all slots as empty (0xFF)
        self.armor = ItemConstants.emptySlot
        self.weapon = ItemConstants.emptySlot
        self.onhandWeapons = Array(repeating: ItemConstants.emptySlot, count: 3)
        self.inventory = Array(repeating: ItemConstants.emptySlot, count: 8)
    }

    init(armor: UInt8, weapon: UInt8, onhandWeapons: [UInt8], inventory: [UInt8]) {
        self.armor = armor
        self.weapon = weapon
        self.onhandWeapons = onhandWeapons
        self.inventory = inventory
    }
}
