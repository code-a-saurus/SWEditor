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

/// Equipment editor for a crew member
/// Provides dropdown menus for armor, weapons, and inventory items
struct EquipmentEditor: View {
    let crew: CrewMember
    let onChanged: () -> Void
    var originalEquipment: Equipment? = nil

    // State variables to track selections (needed for SwiftUI reactivity)
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

    // Initialize state from crew member
    init(crew: CrewMember, onChanged: @escaping () -> Void, originalEquipment: Equipment? = nil) {
        self.crew = crew
        self.onChanged = onChanged
        self.originalEquipment = originalEquipment
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
    }

    // Sorted item lists for dropdowns
    // Always include 0xFF (Empty Slot) and current value to avoid picker errors
    private func armorItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validArmor
        items.insert(0xFF)  // Always allow Empty Slot
        items.insert(currentValue)  // Always include current value
        return items.sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
    }

    private func weaponItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validWeapons
        items.insert(0xFF)  // Always allow Empty Slot
        items.insert(currentValue)  // Always include current value
        return items.sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
    }

    private func inventoryItems(currentValue: UInt8) -> [UInt8] {
        var items = ItemConstants.validInventory
        items.insert(currentValue)  // Always include current value (0xFF already in set)
        return items.sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
    }

    // Helper to update crew member and trigger change callback
    private func updateEquipment<T>(_ keyPath: WritableKeyPath<Equipment, T>, value: T) {
        crew.equipment[keyPath: keyPath] = value
        onChanged()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Equipment for \(crew.name)")
                    .font(.headline)
                    .padding(.bottom, 10)

                // Equipped Armor
                GroupBox(label: Text("Equipped Armor").font(.subheadline).bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(
                            label: "Armor",
                            selectedItemCode: Binding(
                                get: { selectedArmor },
                                set: { newValue in
                                    selectedArmor = newValue
                                    updateEquipment(\.armor, value: newValue)
                                }
                            ),
                            validItems: armorItems(currentValue: selectedArmor),
                            onChange: {},  // updateEquipment already calls onChanged
                            originalItemCode: originalEquipment?.armor
                        )
                    }
                    .padding(10)
                }

                // Equipped Weapon
                GroupBox(label: Text("Equipped Weapon").font(.subheadline).bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(
                            label: "Weapon",
                            selectedItemCode: Binding(
                                get: { selectedWeapon },
                                set: { newValue in
                                    selectedWeapon = newValue
                                    updateEquipment(\.weapon, value: newValue)
                                }
                            ),
                            validItems: weaponItems(currentValue: selectedWeapon),
                            onChange: {},  // updateEquipment already calls onChanged
                            originalItemCode: originalEquipment?.weapon
                        )
                    }
                    .padding(10)
                }

                // On-hand Weapons (3 slots)
                GroupBox(label: Text("On-hand Weapons").font(.subheadline).bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(
                            label: "Slot 1",
                            selectedItemCode: Binding(
                                get: { selectedOnhandWeapon1 },
                                set: { newValue in
                                    selectedOnhandWeapon1 = newValue
                                    updateEquipment(\.onhandWeapon1, value: newValue)
                                }
                            ),
                            validItems: weaponItems(currentValue: selectedOnhandWeapon1),
                            onChange: {},
                            originalItemCode: originalEquipment?.onhandWeapon1
                        )

                        ItemPicker(
                            label: "Slot 2",
                            selectedItemCode: Binding(
                                get: { selectedOnhandWeapon2 },
                                set: { newValue in
                                    selectedOnhandWeapon2 = newValue
                                    updateEquipment(\.onhandWeapon2, value: newValue)
                                }
                            ),
                            validItems: weaponItems(currentValue: selectedOnhandWeapon2),
                            onChange: {},
                            originalItemCode: originalEquipment?.onhandWeapon2
                        )

                        ItemPicker(
                            label: "Slot 3",
                            selectedItemCode: Binding(
                                get: { selectedOnhandWeapon3 },
                                set: { newValue in
                                    selectedOnhandWeapon3 = newValue
                                    updateEquipment(\.onhandWeapon3, value: newValue)
                                }
                            ),
                            validItems: weaponItems(currentValue: selectedOnhandWeapon3),
                            onChange: {},
                            originalItemCode: originalEquipment?.onhandWeapon3
                        )
                    }
                    .padding(10)
                }

                // Inventory (8 slots)
                GroupBox(label: Text("Inventory").font(.subheadline).bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        ItemPicker(
                            label: "Slot 1",
                            selectedItemCode: Binding(
                                get: { selectedInventory1 },
                                set: { newValue in
                                    selectedInventory1 = newValue
                                    updateEquipment(\.inventory1, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory1),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory1
                        )

                        ItemPicker(
                            label: "Slot 2",
                            selectedItemCode: Binding(
                                get: { selectedInventory2 },
                                set: { newValue in
                                    selectedInventory2 = newValue
                                    updateEquipment(\.inventory2, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory2),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory2
                        )

                        ItemPicker(
                            label: "Slot 3",
                            selectedItemCode: Binding(
                                get: { selectedInventory3 },
                                set: { newValue in
                                    selectedInventory3 = newValue
                                    updateEquipment(\.inventory3, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory3),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory3
                        )

                        ItemPicker(
                            label: "Slot 4",
                            selectedItemCode: Binding(
                                get: { selectedInventory4 },
                                set: { newValue in
                                    selectedInventory4 = newValue
                                    updateEquipment(\.inventory4, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory4),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory4
                        )

                        ItemPicker(
                            label: "Slot 5",
                            selectedItemCode: Binding(
                                get: { selectedInventory5 },
                                set: { newValue in
                                    selectedInventory5 = newValue
                                    updateEquipment(\.inventory5, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory5),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory5
                        )

                        ItemPicker(
                            label: "Slot 6",
                            selectedItemCode: Binding(
                                get: { selectedInventory6 },
                                set: { newValue in
                                    selectedInventory6 = newValue
                                    updateEquipment(\.inventory6, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory6),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory6
                        )

                        ItemPicker(
                            label: "Slot 7",
                            selectedItemCode: Binding(
                                get: { selectedInventory7 },
                                set: { newValue in
                                    selectedInventory7 = newValue
                                    updateEquipment(\.inventory7, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory7),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory7
                        )

                        ItemPicker(
                            label: "Slot 8",
                            selectedItemCode: Binding(
                                get: { selectedInventory8 },
                                set: { newValue in
                                    selectedInventory8 = newValue
                                    updateEquipment(\.inventory8, value: newValue)
                                }
                            ),
                            validItems: inventoryItems(currentValue: selectedInventory8),
                            onChange: {},
                            originalItemCode: originalEquipment?.inventory8
                        )
                    }
                    .padding(10)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
