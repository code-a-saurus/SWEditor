// TreeNode.swift
// Sentinel Worlds Editor - Swift Port
//
// Copyright (C) 2025 Lee R.
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

import Foundation

/// Represents a node in the navigation tree sidebar
struct TreeNode: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: NodeType
    let children: [TreeNode]?

    /// Types of tree nodes corresponding to different editors
    enum NodeType: Hashable {
        // Party nodes
        case party
        case partyCash
        case partyLight

        // Ship nodes
        case ship
        case shipSoftware

        // Crew nodes
        case crewRoot
        case crewMember(number: Int)
        case crewCharacteristics(crewNumber: Int)
        case crewAbilities(crewNumber: Int)
        case crewHP(crewNumber: Int)
        case crewEquipment(crewNumber: Int)
    }

    /// Builds the complete navigation tree structure from a SaveGame
    static func buildTree(from saveGame: SaveGame) -> [TreeNode] {
        var nodes: [TreeNode] = []

        // Party node with children
        let partyNode = TreeNode(
            title: "Party",
            type: .party,
            children: [
                TreeNode(title: "Cash", type: .partyCash, children: nil),
                TreeNode(title: "Light Energy", type: .partyLight, children: nil)
            ]
        )
        nodes.append(partyNode)

        // Ship node with children
        let shipNode = TreeNode(
            title: "Ship Software",
            type: .ship,
            children: [
                TreeNode(title: "All Software", type: .shipSoftware, children: nil)
            ]
        )
        nodes.append(shipNode)

        // Crew members node with children
        var crewChildren: [TreeNode] = []
        for i in 0..<5 {
            let crewNumber = i + 1
            let crewMember = saveGame.crew[i]
            let crewTitle = "Crew \(crewNumber): \(crewMember.name)"

            let crewSubNodes = [
                TreeNode(title: "Characteristics", type: .crewCharacteristics(crewNumber: crewNumber), children: nil),
                TreeNode(title: "Abilities", type: .crewAbilities(crewNumber: crewNumber), children: nil),
                TreeNode(title: "Hit Points", type: .crewHP(crewNumber: crewNumber), children: nil),
                TreeNode(title: "Equipment", type: .crewEquipment(crewNumber: crewNumber), children: nil)
            ]

            let crewNode = TreeNode(
                title: crewTitle,
                type: .crewMember(number: crewNumber),
                children: crewSubNodes
            )
            crewChildren.append(crewNode)
        }

        let crewRootNode = TreeNode(
            title: "Crew Members",
            type: .crewRoot,
            children: crewChildren
        )
        nodes.append(crewRootNode)

        return nodes
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.id == rhs.id
    }
}
