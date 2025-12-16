// EquipmentEditor.swift
// SentinelWorldsEditor
//
// Editor for crew member equipment (armor, weapons, inventory)
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
import Combine

/// Equipment editor for a crew member
/// Provides dropdown menus for armor, weapons, and inventory items
struct EquipmentEditor: View {
    let crew: CrewMember
    let saveGame: SaveGame
    let onChanged: () -> Void
    var originalEquipment: Equipment? = nil
    var originalPortrait: UInt8? = nil
    var undoManager: UndoManager? = nil

    @State private var selectedArmor: UInt8
    @State private var selectedWeapon: UInt8
    @State private var selectedOnhandWeapon1: UInt8
    @State private var selectedOnhandWeapon2: UInt8
    @State private var selectedOnhandWeapon3: UInt8
    @State private var selectedInventory1: UInt8
    @State private var selectedInventory2: UInt8
    @State private var selectedInventory3: UInt8
    @State private var selectedInventory4: UInt8
    @State private var selectedInventory5: UInt8
    @State private var selectedInventory6: UInt8
    @State private var selectedInventory7: UInt8
    @State private var selectedInventory8: UInt8
    @State private var portrait: UInt8

    init(crew: CrewMember, saveGame: SaveGame, onChanged: @escaping () -> Void, originalEquipment: Equipment? = nil, originalPortrait: UInt8? = nil, undoManager: UndoManager? = nil) {
        self.crew = crew
        self.saveGame = saveGame
        self.onChanged = onChanged
        self.originalEquipment = originalEquipment
        self.originalPortrait = originalPortrait
        self.undoManager = undoManager
        _selectedArmor = State(initialValue: crew.equipment.armor)
        _selectedWeapon = State(initialValue: crew.equipment.weapon)
        _selectedOnhandWeapon1 = State(initialValue: crew.equipment.onhandWeapon1)
        _selectedOnhandWeapon2 = State(initialValue: crew.equipment.onhandWeapon2)
        _selectedOnhandWeapon3 = State(initialValue: crew.equipment.onhandWeapon3)
        _selectedInventory1 = State(initialValue: crew.equipment.inventory1)
        _selectedInventory2 = State(initialValue: crew.equipment.inventory2)
        _selectedInventory3 = State(initialValue: crew.equipment.inventory3)
        _selectedInventory4 = State(initialValue: crew.equipment.inventory4)
        _selectedInventory5 = State(initialValue: crew.equipment.inventory5)
        _selectedInventory6 = State(initialValue: crew.equipment.inventory6)
        _selectedInventory7 = State(initialValue: crew.equipment.inventory7)
        _selectedInventory8 = State(initialValue: crew.equipment.inventory8)
        _portrait = State(initialValue: crew.portrait)
    }

    private func armorItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validArmor
        items.insert(0xFF); items.insert(currentValue)
        return items.sorted { ItemConstants.itemName(for: $0) < ItemConstants.itemName(for: $1) }
    }

    private func weaponItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validWeapons
        items.insert(0xFF); items.insert(currentValue)
        return items.sorted { ItemConstants.itemName(for: $0) < ItemConstants.itemName(for: $1) }
    }

    private func inventoryItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validInventory
        items.insert(currentValue)
        return items.sorted { ItemConstants.itemName(for: $0) < ItemConstants.itemName(for: $1) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 40) {
            // Left side: Equipment lists (scrollable)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Equipment for \(crew.name)").font(.headline).padding(.bottom, 10)

                GroupBox(label: Text("Equipped Armor").font(.headline)) {
                    ItemPicker(label: "Armor", selectedItemCode: $selectedArmor,
                              validItems: armorItems(currentValue: selectedArmor),
                              onChange: { old, new in
                        let targetCrew = crew
                        let targetSaveGame = saveGame
                        crew.equipment.armor = new
                        undoManager?.registerUndo(withTarget: saveGame) { _ in
                            targetSaveGame.objectWillChange.send()
                            targetCrew.equipment.armor = old
                            onChanged()
                        }
                        undoManager?.setActionName("Change \(crew.name) Armor"); onChanged()
                    }, originalItemCode: originalEquipment?.armor, undoManager: undoManager)
                }.padding(.vertical, 5)

                GroupBox(label: Text("Equipped Weapon").font(.headline)) {
                    ItemPicker(label: "Weapon", selectedItemCode: $selectedWeapon,
                              validItems: weaponItems(currentValue: selectedWeapon),
                              onChange: { old, new in
                        let targetCrew = crew
                        let targetSaveGame = saveGame
                        crew.equipment.weapon = new
                        undoManager?.registerUndo(withTarget: saveGame) { _ in
                            targetSaveGame.objectWillChange.send()
                            targetCrew.equipment.weapon = old
                            onChanged()
                        }
                        undoManager?.setActionName("Change \(crew.name) Weapon"); onChanged()
                    }, originalItemCode: originalEquipment?.weapon, undoManager: undoManager)
                }.padding(.vertical, 5)

                GroupBox(label: Text("On-Hand Weapons (3 slots)").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(label: "Slot 1", selectedItemCode: $selectedOnhandWeapon1,
                                  validItems: weaponItems(currentValue: selectedOnhandWeapon1),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.onhandWeapon1 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.onhandWeapon1 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) On-Hand Weapon 1"); onChanged()
                        }, originalItemCode: originalEquipment?.onhandWeapon1, undoManager: undoManager)

                        ItemPicker(label: "Slot 2", selectedItemCode: $selectedOnhandWeapon2,
                                  validItems: weaponItems(currentValue: selectedOnhandWeapon2),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.onhandWeapon2 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.onhandWeapon2 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) On-Hand Weapon 2"); onChanged()
                        }, originalItemCode: originalEquipment?.onhandWeapon2, undoManager: undoManager)

                        ItemPicker(label: "Slot 3", selectedItemCode: $selectedOnhandWeapon3,
                                  validItems: weaponItems(currentValue: selectedOnhandWeapon3),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.onhandWeapon3 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.onhandWeapon3 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) On-Hand Weapon 3"); onChanged()
                        }, originalItemCode: originalEquipment?.onhandWeapon3, undoManager: undoManager)
                    }
                }.padding(.vertical, 5)

                GroupBox(label: Text("Inventory (8 slots)").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(label: "Slot 1", selectedItemCode: $selectedInventory1,
                                  validItems: inventoryItems(currentValue: selectedInventory1),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory1 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory1 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 1"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory1, undoManager: undoManager)

                        ItemPicker(label: "Slot 2", selectedItemCode: $selectedInventory2,
                                  validItems: inventoryItems(currentValue: selectedInventory2),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory2 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory2 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 2"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory2, undoManager: undoManager)

                        ItemPicker(label: "Slot 3", selectedItemCode: $selectedInventory3,
                                  validItems: inventoryItems(currentValue: selectedInventory3),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory3 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory3 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 3"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory3, undoManager: undoManager)

                        ItemPicker(label: "Slot 4", selectedItemCode: $selectedInventory4,
                                  validItems: inventoryItems(currentValue: selectedInventory4),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory4 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory4 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 4"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory4, undoManager: undoManager)

                        ItemPicker(label: "Slot 5", selectedItemCode: $selectedInventory5,
                                  validItems: inventoryItems(currentValue: selectedInventory5),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory5 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory5 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 5"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory5, undoManager: undoManager)

                        ItemPicker(label: "Slot 6", selectedItemCode: $selectedInventory6,
                                  validItems: inventoryItems(currentValue: selectedInventory6),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory6 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory6 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 6"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory6, undoManager: undoManager)

                        ItemPicker(label: "Slot 7", selectedItemCode: $selectedInventory7,
                                  validItems: inventoryItems(currentValue: selectedInventory7),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory7 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory7 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 7"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory7, undoManager: undoManager)

                        ItemPicker(label: "Slot 8", selectedItemCode: $selectedInventory8,
                                  validItems: inventoryItems(currentValue: selectedInventory8),
                                  onChange: { old, new in
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.equipment.inventory8 = new
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.equipment.inventory8 = old
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Inventory 8"); onChanged()
                        }, originalItemCode: originalEquipment?.inventory8, undoManager: undoManager)
                    }
                }.padding(.vertical, 5)
                }
                .padding()
            }

            // Right side: Portrait display and picker
            VStack(alignment: .trailing) {
                PortraitPicker(
                    selectedPortrait: $portrait,
                    onChange: { oldValue, newValue in
                        // When portrait changes, register undo and mark as changed
                        if oldValue != newValue && crew.portrait != newValue {
                            let targetCrew = crew
                            let targetSaveGame = saveGame
                            crew.portrait = newValue

                            // Register undo action - use saveGame as target for truly global undo
                            undoManager?.registerUndo(withTarget: saveGame) { _ in
                                targetSaveGame.objectWillChange.send()
                                targetCrew.portrait = oldValue
                                onChanged()
                            }
                            undoManager?.setActionName("Change \(crew.name) Portrait")

                            onChanged()
                        }
                    },
                    originalPortrait: originalPortrait,
                    undoManager: undoManager
                )
                .padding(.top)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(saveGame.objectWillChange) { _ in
            // Sync @State when saveGame changes (from undo/redo)
            portrait = crew.portrait
        }
    }
}
