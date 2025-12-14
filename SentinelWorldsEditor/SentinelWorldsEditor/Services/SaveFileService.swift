//
// SaveFileService.swift
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

/// Service for loading and saving Sentinel Worlds save files
class SaveFileService {

    // MARK: - Loading

    /// Loads a save game from a file
    ///
    /// - Parameter url: URL of the save file to load
    /// - Returns: Populated SaveGame object
    /// - Throws: SaveFileValidator.ValidationError or file I/O errors
    static func load(from url: URL) throws -> SaveGame {
        // Validate file first
        try SaveFileValidator.validate(url: url)

        // Open file for reading
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        // Create save game object
        let saveGame = SaveGame()
        saveGame.fileURL = url

        // Load party data
        saveGame.party.cash = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Party.cashAddress,
            numBytes: SaveFileConstants.Party.cashLength
        )
        saveGame.party.lightEnergy = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Party.lightEnergyAddress,
            numBytes: 1
        )

        // Load ship data
        saveGame.ship.move = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Ship.moveAddress,
            numBytes: 1
        )
        saveGame.ship.target = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Ship.targetAddress,
            numBytes: 1
        )
        saveGame.ship.engine = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Ship.engineAddress,
            numBytes: 1
        )
        saveGame.ship.laser = try BinaryFileIO.readBytes(
            from: fileHandle,
            address: SaveFileConstants.Ship.laserAddress,
            numBytes: 1
        )

        // Load crew data
        for crewNumber in 1...5 {
            let crew = saveGame.crew[crewNumber - 1]
            let addrs = SaveFileConstants.crewAddresses(for: crewNumber)

            // Name
            crew.name = try BinaryFileIO.readString(
                from: fileHandle,
                address: addrs.nameAddress,
                length: addrs.nameLength
            )

            // Basic stats
            crew.rank = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.rankAddress,
                numBytes: 1
            )
            crew.hp = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.hpAddress,
                numBytes: 1
            )

            // Characteristics
            crew.characteristics.strength = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.characteristics.strength,
                numBytes: 1
            )
            crew.characteristics.stamina = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.characteristics.stamina,
                numBytes: 1
            )
            crew.characteristics.dexterity = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.characteristics.dexterity,
                numBytes: 1
            )
            crew.characteristics.comprehend = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.characteristics.comprehend,
                numBytes: 1
            )
            crew.characteristics.charisma = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.characteristics.charisma,
                numBytes: 1
            )

            // Abilities
            crew.abilities.contact = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.contact,
                numBytes: 1
            )
            crew.abilities.edged = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.edged,
                numBytes: 1
            )
            crew.abilities.projectile = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.projectile,
                numBytes: 1
            )
            crew.abilities.blaster = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.blaster,
                numBytes: 1
            )
            crew.abilities.tactics = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.tactics,
                numBytes: 1
            )
            crew.abilities.recon = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.recon,
                numBytes: 1
            )
            crew.abilities.gunnery = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.gunnery,
                numBytes: 1
            )
            crew.abilities.atvRepair = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.atvRepair,
                numBytes: 1
            )
            crew.abilities.mining = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.mining,
                numBytes: 1
            )
            crew.abilities.athletics = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.athletics,
                numBytes: 1
            )
            crew.abilities.observation = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.observation,
                numBytes: 1
            )
            crew.abilities.bribery = try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.abilities.bribery,
                numBytes: 1
            )

            // Equipment
            crew.equipment.armor = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.armorAddress,
                numBytes: 1
            ))
            crew.equipment.weapon = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.weaponAddress,
                numBytes: 1
            ))

            // On-hand weapons (3 consecutive bytes)
            crew.equipment.onhandWeapon1 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.onhandWeaponsStart,
                numBytes: 1
            ))
            crew.equipment.onhandWeapon2 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.onhandWeaponsStart + 1,
                numBytes: 1
            ))
            crew.equipment.onhandWeapon3 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.onhandWeaponsStart + 2,
                numBytes: 1
            ))

            // Inventory (8 consecutive bytes)
            crew.equipment.inventory1 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart,
                numBytes: 1
            ))
            crew.equipment.inventory2 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 1,
                numBytes: 1
            ))
            crew.equipment.inventory3 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 2,
                numBytes: 1
            ))
            crew.equipment.inventory4 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 3,
                numBytes: 1
            ))
            crew.equipment.inventory5 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 4,
                numBytes: 1
            ))
            crew.equipment.inventory6 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 5,
                numBytes: 1
            ))
            crew.equipment.inventory7 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 6,
                numBytes: 1
            ))
            crew.equipment.inventory8 = UInt8(try BinaryFileIO.readBytes(
                from: fileHandle,
                address: addrs.inventoryStart + 7,
                numBytes: 1
            ))
        }

        // Mark as no unsaved changes since we just loaded
        saveGame.hasUnsavedChanges = false

        return saveGame
    }

    // MARK: - Saving

    /// Saves a save game to a file
    ///
    /// Creates a .bak backup before writing changes.
    /// This is a placeholder for Phase 4 - not implemented yet for Phase 3 read-only viewer.
    ///
    /// - Parameters:
    ///   - saveGame: The SaveGame object to save
    ///   - url: URL to save to
    /// - Throws: File I/O errors
    static func save(_ saveGame: SaveGame, to url: URL) throws {
        // TODO: Phase 4 - Implement save functionality
        // 1. Create .bak backup
        // 2. Write all values using BinaryFileIO
        // 3. Clear hasUnsavedChanges flag
        fatalError("Save functionality not yet implemented (Phase 4)")
    }
}
