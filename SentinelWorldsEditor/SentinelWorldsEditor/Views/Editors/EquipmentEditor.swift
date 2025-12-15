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

    // Sorted item lists for dropdowns
    private var armorItems: [UInt8] {
        Array(ItemConstants.validArmor).sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
    }

    private var weaponItems: [UInt8] {
        Array(ItemConstants.validWeapons).sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
    }

    private var inventoryItems: [UInt8] {
        Array(ItemConstants.validInventory).sorted { itemA, itemB in
            ItemConstants.itemName(for: itemA) < ItemConstants.itemName(for: itemB)
        }
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
                                get: { crew.equipment.armor },
                                set: { crew.equipment.armor = $0 }
                            ),
                            validItems: armorItems,
                            onChange: onChanged
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
                                get: { crew.equipment.weapon },
                                set: { crew.equipment.weapon = $0 }
                            ),
                            validItems: weaponItems,
                            onChange: onChanged
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
                                get: { crew.equipment.onhandWeapon1 },
                                set: { crew.equipment.onhandWeapon1 = $0 }
                            ),
                            validItems: weaponItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 2",
                            selectedItemCode: Binding(
                                get: { crew.equipment.onhandWeapon2 },
                                set: { crew.equipment.onhandWeapon2 = $0 }
                            ),
                            validItems: weaponItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 3",
                            selectedItemCode: Binding(
                                get: { crew.equipment.onhandWeapon3 },
                                set: { crew.equipment.onhandWeapon3 = $0 }
                            ),
                            validItems: weaponItems,
                            onChange: onChanged
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
                                get: { crew.equipment.inventory1 },
                                set: { crew.equipment.inventory1 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 2",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory2 },
                                set: { crew.equipment.inventory2 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 3",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory3 },
                                set: { crew.equipment.inventory3 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 4",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory4 },
                                set: { crew.equipment.inventory4 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 5",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory5 },
                                set: { crew.equipment.inventory5 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 6",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory6 },
                                set: { crew.equipment.inventory6 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 7",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory7 },
                                set: { crew.equipment.inventory7 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
                        )

                        ItemPicker(
                            label: "Slot 8",
                            selectedItemCode: Binding(
                                get: { crew.equipment.inventory8 },
                                set: { crew.equipment.inventory8 = $0 }
                            ),
                            validItems: inventoryItems,
                            onChange: onChanged
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
