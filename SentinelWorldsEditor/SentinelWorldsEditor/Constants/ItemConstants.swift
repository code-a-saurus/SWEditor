//
// ItemConstants.swift
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

/// Game item constants, lookup tables, and validation sets
///
/// This module provides:
/// - Item hex codes (0x00-0xFF)
/// - Human-readable item names
/// - Validation sets for armor, weapons, ammo, and inventory
struct ItemConstants {

    // MARK: - Item Codes

    // Special
    static let emptySlot: UInt8 = 0xFF

    // Miscellaneous items
    static let burbulator: UInt8 = 0x00
    static let eaPasscard: UInt8 = 0x01
    static let trinoculars: UInt8 = 0x02
    static let arisianLens: UInt8 = 0x03
    static let mysteriousArmor: UInt8 = 0x04
    static let energyBall: UInt8 = 0x05
    static let ancientArmor: UInt8 = 0x06
    static let book: UInt8 = 0x07

    // Natural weapons
    static let hands: UInt8 = 0x08
    static let claws: UInt8 = 0x1C
    static let teeth: UInt8 = 0x1D
    static let thrasher: UInt8 = 0x1E
    static let acidBreath: UInt8 = 0x1F

    // Melee weapons
    static let powerfist: UInt8 = 0x09
    static let sonicMace: UInt8 = 0x0A
    static let gyroPike: UInt8 = 0x0B
    static let neuronFlail: UInt8 = 0x0C
    static let dagger: UInt8 = 0x0D
    static let cryoCutlas: UInt8 = 0x0E
    static let powerAxe: UInt8 = 0x0F
    static let energyBlade: UInt8 = 0x10
    static let edgeSpinner: UInt8 = 0x11

    // Projectile weapons
    static let autoPistol: UInt8 = 0x12
    static let shotgun: UInt8 = 0x13
    static let hyperuzi: UInt8 = 0x14
    static let ak4700: UInt8 = 0x15
    static let gaussRifle: UInt8 = 0x16

    // Energy weapons
    static let thermocaster: UInt8 = 0x17
    static let handLaser: UInt8 = 0x18
    static let lrLaser: UInt8 = 0x19
    static let plasmaGun: UInt8 = 0x1A
    static let neutronGun: UInt8 = 0x1B
    static let nerfCannon: UInt8 = 0x37

    // Special items
    static let tesselator: UInt8 = 0x20
    static let nanobot: UInt8 = 0x21
    static let markVTeng: UInt8 = 0x22
    static let vadroxon: UInt8 = 0x23

    // Armor
    static let uniform: UInt8 = 0x24
    static let flightJacket: UInt8 = 0x25
    static let steelMesh: UInt8 = 0x26
    static let flakJacket: UInt8 = 0x27
    static let laserReflec: UInt8 = 0x28
    static let combatArmor: UInt8 = 0x29
    static let thickSkin: UInt8 = 0x2A
    static let roughSkin: UInt8 = 0x2B
    static let thickFur: UInt8 = 0x2C
    static let carbonArmor: UInt8 = 0x2D
    static let civilianClothes: UInt8 = 0x2E
    static let special: UInt8 = 0x2F
    static let kevlarSuit: UInt8 = 0x38

    // Ammunition and power cells
    static let autoClip: UInt8 = 0x30
    static let shotgunPack: UInt8 = 0x31
    static let hyperuziMag: UInt8 = 0x32
    static let gaussRifleMag: UInt8 = 0x33
    static let ak4700Mag: UInt8 = 0x34
    static let thermPak: UInt8 = 0x35
    static let crysprism: UInt8 = 0x36

    // Miscellaneous (continued)
    static let holophones: UInt8 = 0x39
    static let vaxGrapher: UInt8 = 0x3A
    static let antiqueYoyo: UInt8 = 0x3B
    static let cryoscope: UInt8 = 0x3C
    static let cyberdisk: UInt8 = 0x3D
    static let szartNeedle: UInt8 = 0x3E
    static let knarlybar: UInt8 = 0x3F

    // MARK: - Item Names Lookup

    /// Dictionary mapping item codes to human-readable names
    static let itemNames: [UInt8: String] = [
        // Special
        0xFF: "Empty Slot",

        // Miscellaneous
        0x00: "Burbulator",
        0x01: "Ea Passcard",
        0x02: "Trinoculars",
        0x03: "Arisian Lens",
        0x05: "Energy Ball",
        0x07: "Book",
        0x20: "Tesselator",
        0x21: "Nanobot",
        0x22: "Mark V Teng",
        0x23: "Vadroxon",
        0x39: "Holophones",
        0x3A: "Vax Grapher",
        0x3B: "Antique Yoyo",
        0x3C: "Cryoscope",
        0x3D: "Cyberdisk",
        0x3E: "Szart Needle",
        0x3F: "Knarlybar",

        // Natural weapons
        0x08: "Hands",
        0x1C: "Claws",
        0x1D: "Teeth",
        0x1E: "Thrasher",
        0x1F: "Acid Breath",

        // Melee weapons
        0x09: "Powerfist",
        0x0A: "Sonic Mace",
        0x0B: "Gyro Pike",
        0x0C: "Neuron Flail",
        0x0D: "Dagger",
        0x0E: "Cryo Cutlas",
        0x0F: "Power Axe",
        0x10: "Energy Blade",
        0x11: "Edge Spinner",

        // Projectile weapons
        0x12: "Auto Pistol",
        0x13: "Shotgun",
        0x14: "Hyperuzi",
        0x15: "Ak 4700",
        0x16: "Gauss Rifle",

        // Energy weapons
        0x17: "Thermocaster",
        0x18: "Hand Laser",
        0x19: "Lr Laser",
        0x1A: "Plasma Gun",
        0x1B: "Neutron Gun",
        0x37: "Nerf Cannon",

        // Armor
        0x04: "Mysterious Armor",
        0x06: "Ancient Armor",
        0x24: "Uniform",
        0x25: "Flight Jacket",
        0x26: "Steel Mesh",
        0x27: "Flak Jacket",
        0x28: "Laser Reflec",
        0x29: "Combat Armor",
        0x2A: "Thick Skin",
        0x2B: "Rough Skin",
        0x2C: "Thick Fur",
        0x2D: "Carbon Armor",
        0x2E: "Civilian Clothes",
        0x2F: "Special",
        0x38: "Kevlar Suit",

        // Ammunition and power cells
        0x30: "Auto Clip",
        0x31: "Shotgun Pack",
        0x32: "Hyperuzi Mag",
        0x33: "Gauss Rifle Mag",
        0x34: "Ak 4700 Mag",
        0x35: "Therm Pak",
        0x36: "Crysprism"
    ]

    // MARK: - Validation Sets

    /// Valid armor items (15 items total)
    static let validArmor: Set<UInt8> = [
        0x04,  // Mysterious Armor
        0x06,  // Ancient Armor
        0x24,  // Uniform
        0x25,  // Flight Jacket
        0x26,  // Steel Mesh
        0x27,  // Flak Jacket
        0x28,  // Laser Reflec
        0x29,  // Combat Armor
        0x2A,  // Thick Skin
        0x2B,  // Rough Skin
        0x2C,  // Thick Fur
        0x2D,  // Carbon Armor
        0x2E,  // Civilian Clothes
        0x2F,  // Special
        0x38   // Kevlar Suit
    ]

    /// Valid weapons (25 items total)
    static let validWeapons: Set<UInt8> = [
        0x08,  // Hands
        0x09,  // Powerfist
        0x0A,  // Sonic Mace
        0x0B,  // Gyro Pike
        0x0C,  // Neuron Flail
        0x0D,  // Dagger
        0x0E,  // Cryo Cutlas
        0x0F,  // Power Axe
        0x10,  // Energy Blade
        0x11,  // Edge Spinner
        0x12,  // Auto Pistol
        0x13,  // Shotgun
        0x14,  // Hyperuzi
        0x15,  // AK 4700
        0x16,  // Gauss Rifle
        0x17,  // Thermocaster
        0x18,  // Hand Laser
        0x19,  // LR Laser
        0x1A,  // Plasma Gun
        0x1B,  // Neutron Gun
        0x1C,  // Claws
        0x1D,  // Teeth
        0x1E,  // Thrasher
        0x1F,  // Acid Breath
        0x37   // Nerf Cannon
    ]

    /// Valid ammunition and power cells (7 items total)
    static let validAmmo: Set<UInt8> = [
        0x30,  // Auto Clip
        0x31,  // Shotgun Pack
        0x32,  // Hyperuzi Mag
        0x33,  // Gauss Rifle Mag
        0x34,  // AK 4700 Mag
        0x35,  // Therm Pak
        0x36   // Crysprism
    ]

    /// Valid inventory items (includes ammo + miscellaneous items)
    static let validInventory: Set<UInt8> = [
        0xFF,  // Empty Slot
        0x00,  // Burbulator
        0x01,  // EA Passcard
        0x02,  // Trinoculars
        0x03,  // Arisian Lens
        0x05,  // Energy Ball
        0x07,  // Book
        0x20,  // Tesselator
        0x21,  // Nanobot
        0x22,  // Mark V Teng
        0x23,  // Vadroxon
        0x39,  // Holophones
        0x3A,  // Vax Grapher
        0x3B,  // Antique Yoyo
        0x3C,  // Cryoscope
        0x3D,  // Cyberdisk
        0x3E,  // Szart Needle
        0x3F,  // Knarlybar
        // Union with ammo
        0x30,  // Auto Clip
        0x31,  // Shotgun Pack
        0x32,  // Hyperuzi Mag
        0x33,  // Gauss Rifle Mag
        0x34,  // AK 4700 Mag
        0x35,  // Therm Pak
        0x36   // Crysprism
    ]

    // MARK: - Helper Functions

    /// Get human-readable name for an item code
    ///
    /// - Parameter code: Item hex code (0x00-0xFF)
    /// - Returns: Item name, or "Unknown Item (0xXX)" if not found
    static func itemName(for code: UInt8) -> String {
        return itemNames[code] ?? "Unknown Item (0x\(String(format: "%02X", code)))"
    }

    /// Check if an item code is valid armor
    static func isValidArmor(_ code: UInt8) -> Bool {
        return validArmor.contains(code)
    }

    /// Check if an item code is a valid weapon
    static func isValidWeapon(_ code: UInt8) -> Bool {
        return validWeapons.contains(code)
    }

    /// Check if an item code is valid ammo
    static func isValidAmmo(_ code: UInt8) -> Bool {
        return validAmmo.contains(code)
    }

    /// Check if an item code is valid for inventory
    static func isValidInventory(_ code: UInt8) -> Bool {
        return validInventory.contains(code)
    }
}
