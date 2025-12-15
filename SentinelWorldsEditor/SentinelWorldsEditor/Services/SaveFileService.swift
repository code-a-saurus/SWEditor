//
// SaveFileService.swift
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
    ///
    /// - Parameters:
    ///   - saveGame: The SaveGame object to save
    ///   - url: URL to save to
    /// - Throws: File I/O errors or validation errors
    static func save(_ saveGame: SaveGame, to url: URL) throws {
        let fileManager = FileManager.default

        // Validate file is writable (directory must be writable for backup)
        try SaveFileValidator.validate(url: url, requireWritable: true)

        // Create .bak backup file
        let backupURL = url.deletingPathExtension().appendingPathExtension("bak")
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
        try fileManager.copyItem(at: url, to: backupURL)

        // Open file for writing
        let fileHandle = try FileHandle(forWritingTo: url)
        defer { try? fileHandle.close() }

        // Write party data
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Party.cashAddress,
            value: saveGame.party.cash,
            numBytes: SaveFileConstants.Party.cashLength
        )
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Party.lightEnergyAddress,
            value: saveGame.party.lightEnergy,
            numBytes: 1
        )

        // Write ship data
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Ship.moveAddress,
            value: saveGame.ship.move,
            numBytes: 1
        )
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Ship.targetAddress,
            value: saveGame.ship.target,
            numBytes: 1
        )
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Ship.engineAddress,
            value: saveGame.ship.engine,
            numBytes: 1
        )
        try BinaryFileIO.writeBytes(
            to: fileHandle,
            address: SaveFileConstants.Ship.laserAddress,
            value: saveGame.ship.laser,
            numBytes: 1
        )

        // Write crew data
        for crewNumber in 1...5 {
            let crew = saveGame.crew[crewNumber - 1]
            let addrs = SaveFileConstants.crewAddresses(for: crewNumber)

            // Name
            try BinaryFileIO.writeString(
                to: fileHandle,
                address: addrs.nameAddress,
                value: crew.name,
                length: addrs.nameLength
            )

            // Basic stats
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.rankAddress,
                value: crew.rank,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.hpAddress,
                value: crew.hp,
                numBytes: 1
            )

            // Characteristics
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.characteristics.strength,
                value: crew.characteristics.strength,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.characteristics.stamina,
                value: crew.characteristics.stamina,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.characteristics.dexterity,
                value: crew.characteristics.dexterity,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.characteristics.comprehend,
                value: crew.characteristics.comprehend,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.characteristics.charisma,
                value: crew.characteristics.charisma,
                numBytes: 1
            )

            // Abilities
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.contact,
                value: crew.abilities.contact,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.edged,
                value: crew.abilities.edged,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.projectile,
                value: crew.abilities.projectile,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.blaster,
                value: crew.abilities.blaster,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.tactics,
                value: crew.abilities.tactics,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.recon,
                value: crew.abilities.recon,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.gunnery,
                value: crew.abilities.gunnery,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.atvRepair,
                value: crew.abilities.atvRepair,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.mining,
                value: crew.abilities.mining,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.athletics,
                value: crew.abilities.athletics,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.observation,
                value: crew.abilities.observation,
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.abilities.bribery,
                value: crew.abilities.bribery,
                numBytes: 1
            )

            // Equipment
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.armorAddress,
                value: Int(crew.equipment.armor),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.weaponAddress,
                value: Int(crew.equipment.weapon),
                numBytes: 1
            )

            // On-hand weapons (3 consecutive bytes)
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.onhandWeaponsStart,
                value: Int(crew.equipment.onhandWeapon1),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.onhandWeaponsStart + 1,
                value: Int(crew.equipment.onhandWeapon2),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.onhandWeaponsStart + 2,
                value: Int(crew.equipment.onhandWeapon3),
                numBytes: 1
            )

            // Inventory (8 consecutive bytes)
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart,
                value: Int(crew.equipment.inventory1),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 1,
                value: Int(crew.equipment.inventory2),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 2,
                value: Int(crew.equipment.inventory3),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 3,
                value: Int(crew.equipment.inventory4),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 4,
                value: Int(crew.equipment.inventory5),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 5,
                value: Int(crew.equipment.inventory6),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 6,
                value: Int(crew.equipment.inventory7),
                numBytes: 1
            )
            try BinaryFileIO.writeBytes(
                to: fileHandle,
                address: addrs.inventoryStart + 7,
                value: Int(crew.equipment.inventory8),
                numBytes: 1
            )
        }

        // Mark as no unsaved changes
        saveGame.hasUnsavedChanges = false
    }
}
