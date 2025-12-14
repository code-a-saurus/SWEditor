//
// SaveFileConstants.swift
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

/// Hex addresses and constants for Sentinel Worlds save file format
///
/// This struct replaces Python's globals() dynamic lookup with type-safe static constants.
/// All addresses are in hexadecimal and match the original MS-DOS save file structure.
struct SaveFileConstants {

    // MARK: - Party-Wide Values

    struct Party {
        static let cashAddress = 0x024C
        static let cashLength = 3  // 3-byte value
        static let lightEnergyAddress = 0x023E
    }

    // MARK: - Ship Software

    struct Ship {
        static let moveAddress = 0x25E8
        static let targetAddress = 0x25E9
        static let engineAddress = 0x25EA
        static let laserAddress = 0x25EB
    }

    // MARK: - Crew Member Structure

    /// Addresses for a single crew member
    /// Use `crewAddresses(for:)` to get the appropriate struct for crew 1-5
    struct CrewAddresses {
        let crewNumber: Int
        let rankAddress: Int
        let hpAddress: Int
        let armorAddress: Int
        let weaponAddress: Int
        let onhandWeaponsStart: Int
        let inventoryStart: Int
        let nameAddress: Int
        let nameLength: Int
        let characteristics: CharacteristicAddresses
        let abilities: AbilityAddresses

        struct CharacteristicAddresses {
            let strength: Int
            let stamina: Int
            let dexterity: Int
            let comprehend: Int
            let charisma: Int
        }

        struct AbilityAddresses {
            let contact: Int
            let edged: Int
            let projectile: Int
            let blaster: Int
            let tactics: Int
            let recon: Int
            let gunnery: Int
            let atvRepair: Int
            let mining: Int
            let athletics: Int
            let observation: Int
            let bribery: Int
        }
    }

    // MARK: - Crew Member Address Lookup

    /// Get addresses for a specific crew member (1-5)
    ///
    /// - Parameter crewNumber: Crew member number (1-5)
    /// - Returns: Address structure for that crew member
    static func crewAddresses(for crewNumber: Int) -> CrewAddresses {
        precondition(crewNumber >= 1 && crewNumber <= 5, "Crew number must be 1-5")

        switch crewNumber {
        case 1:
            return CrewAddresses(
                crewNumber: 1,
                rankAddress: 0x023B,
                hpAddress: 0x0236,
                armorAddress: 0x0262,
                weaponAddress: 0x0263,
                onhandWeaponsStart: 0x0265,
                inventoryStart: 0x0220,
                nameAddress: 0x01C1,
                nameLength: 0x0F,
                characteristics: CrewAddresses.CharacteristicAddresses(
                    strength: 0x0230,
                    stamina: 0x0231,
                    dexterity: 0x0232,
                    comprehend: 0x0233,
                    charisma: 0x0234
                ),
                abilities: CrewAddresses.AbilityAddresses(
                    contact: 0x01D0,
                    edged: 0x01D1,
                    projectile: 0x01D2,
                    blaster: 0x01D3,
                    tactics: 0x01D4,
                    recon: 0x01D5,
                    gunnery: 0x01D8,
                    atvRepair: 0x01D9,
                    mining: 0x01DA,
                    athletics: 0x01DB,
                    observation: 0x01DC,
                    bribery: 0x01DD
                )
            )

        case 2:
            return CrewAddresses(
                crewNumber: 2,
                rankAddress: 0x02FB,
                hpAddress: 0x02F6,
                armorAddress: 0x0322,
                weaponAddress: 0x0323,
                onhandWeaponsStart: 0x0325,
                inventoryStart: 0x02E0,
                nameAddress: 0x0281,
                nameLength: 0x0F,
                characteristics: CrewAddresses.CharacteristicAddresses(
                    strength: 0x02F0,
                    stamina: 0x02F1,
                    dexterity: 0x02F2,
                    comprehend: 0x02F3,
                    charisma: 0x02F4
                ),
                abilities: CrewAddresses.AbilityAddresses(
                    contact: 0x0290,
                    edged: 0x0291,
                    projectile: 0x0292,
                    blaster: 0x0293,
                    tactics: 0x0294,
                    recon: 0x0295,
                    gunnery: 0x0298,
                    atvRepair: 0x0299,
                    mining: 0x029A,
                    athletics: 0x029B,
                    observation: 0x029C,
                    bribery: 0x029D
                )
            )

        case 3:
            return CrewAddresses(
                crewNumber: 3,
                rankAddress: 0x03BB,
                hpAddress: 0x03B5,
                armorAddress: 0x03E2,
                weaponAddress: 0x03E3,
                onhandWeaponsStart: 0x03E5,
                inventoryStart: 0x03A0,
                nameAddress: 0x0341,
                nameLength: 0x0F,
                characteristics: CrewAddresses.CharacteristicAddresses(
                    strength: 0x03B0,
                    stamina: 0x03B1,
                    dexterity: 0x03B2,
                    comprehend: 0x03B3,
                    charisma: 0x03B4
                ),
                abilities: CrewAddresses.AbilityAddresses(
                    contact: 0x0350,
                    edged: 0x0351,
                    projectile: 0x0352,
                    blaster: 0x0353,
                    tactics: 0x0354,
                    recon: 0x0355,
                    gunnery: 0x0358,
                    atvRepair: 0x0359,
                    mining: 0x035A,
                    athletics: 0x035B,
                    observation: 0x035C,
                    bribery: 0x035D
                )
            )

        case 4:
            return CrewAddresses(
                crewNumber: 4,
                rankAddress: 0x047B,
                hpAddress: 0x0475,
                armorAddress: 0x04A2,
                weaponAddress: 0x04A3,
                onhandWeaponsStart: 0x04A5,
                inventoryStart: 0x0460,
                nameAddress: 0x0401,
                nameLength: 0x0F,
                characteristics: CrewAddresses.CharacteristicAddresses(
                    strength: 0x0470,
                    stamina: 0x0471,
                    dexterity: 0x0472,
                    comprehend: 0x0473,
                    charisma: 0x0474
                ),
                abilities: CrewAddresses.AbilityAddresses(
                    contact: 0x0410,
                    edged: 0x0411,
                    projectile: 0x0412,
                    blaster: 0x0413,
                    tactics: 0x0414,
                    recon: 0x0415,
                    gunnery: 0x0418,
                    atvRepair: 0x0419,
                    mining: 0x041A,
                    athletics: 0x041B,
                    observation: 0x041C,
                    bribery: 0x041D
                )
            )

        case 5:
            return CrewAddresses(
                crewNumber: 5,
                rankAddress: 0x053B,
                hpAddress: 0x0536,
                armorAddress: 0x0562,
                weaponAddress: 0x0563,
                onhandWeaponsStart: 0x0565,
                inventoryStart: 0x0520,
                nameAddress: 0x04C1,
                nameLength: 0x0F,
                characteristics: CrewAddresses.CharacteristicAddresses(
                    strength: 0x0530,
                    stamina: 0x0531,
                    dexterity: 0x0532,
                    comprehend: 0x0533,
                    charisma: 0x0534
                ),
                abilities: CrewAddresses.AbilityAddresses(
                    contact: 0x04D0,
                    edged: 0x04D1,
                    projectile: 0x04D2,
                    blaster: 0x04D3,
                    tactics: 0x04D4,
                    recon: 0x04D5,
                    gunnery: 0x04D8,
                    atvRepair: 0x04D9,
                    mining: 0x04DA,
                    athletics: 0x04DB,
                    observation: 0x04DC,
                    bribery: 0x04DD
                )
            )

        default:
            fatalError("Crew number must be 1-5")
        }
    }

    // MARK: - Equipment Slot Counts

    static let onhandWeaponSlots = 3
    static let inventorySlots = 8

    // MARK: - Max Values

    struct MaxValues {
        static let cash = 655359
        static let lightEnergy = 254
        static let shipSoftware = 8
        static let stat = 254  // For characteristics and abilities
        static let hp = 125
    }

    // MARK: - Save File Validation

    struct Validation {
        static let signatureAddress = 0x3181
        static let signature = Data("Sentinel".utf8)
        static let maxFileSize = 16384  // 16KB - actual save files are ~12KB
        static let minFileSize = 1024   // 1KB
    }
}
