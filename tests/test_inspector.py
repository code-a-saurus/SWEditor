#!/usr/bin/env python3
"""
Sentinel Worlds I: Future Magic Save Game Inspector
A test script that reads and displays all values from a save game file
"""

import os
import sys
from typing import Dict, Any
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from src.main import load_save_game, initialize_save_data, SAVE_FILE_A, SAVE_FILE_B
from src.inventory_constants import ITEM_NAMES

def format_dict(d: Dict[str, Any], indent: int = 0) -> str:
    """Format a nested dictionary for pretty printing."""
    output = []
    for key, value in d.items():
        if isinstance(value, dict):
            output.append(" " * indent + f"{key}:")
            output.append(format_dict(value, indent + 2))
        elif isinstance(value, list):
            output.append(" " * indent + f"{key}:")
            for i, item in enumerate(value):
                # Special handling for equipment items - show hex and name
                if key in ['onhand_weapons', 'inventory']:
                    item_name = ITEM_NAMES.get(item, f"Unknown item {hex(item)}")
                    output.append(" " * (indent + 2) + f"[{i}] {hex(item)} - {item_name}")
                else:
                    output.append(" " * (indent + 2) + f"[{i}] {item}")
        else:
            # Special handling for equipment items in non-list context
            if key in ['armor', 'weapon']:
                item_name = ITEM_NAMES.get(value, f"Unknown item {hex(value)}")
                output.append(" " * indent + f"{key}: {hex(value)} - {item_name}")
            else:
                output.append(" " * indent + f"{key}: {value}")
    return "\n".join(output)

def inspect_save_game(filename: str) -> None:
    """Load and display all values from a save game file."""
    print(f"\nInspecting save file: {filename}")
    print("=" * 50)
    
    try:
        # Load the save game data
        save_data = load_save_game(filename)
        
        # Display party-wide values
        print("\nParty Values:")
        print("-" * 20)
        print(f"Cash: {save_data['party']['cash']}")
        print(f"Light Energy: {save_data['party']['light_energy']}")
        
        # Display ship values
        print("\nShip Software:")
        print("-" * 20)
        print(format_dict(save_data['ship']))
        
        # Display each crew member's data
        for crew_num in range(1, 6):
            print(f"\nCrew Member {crew_num}:")
            print("-" * 20)
            print(format_dict(save_data['crew'][crew_num]))
            
    except Exception as e:
        print(f"Error inspecting save file: {e}")

def main():
    """Main entry point for the inspector."""
    if not os.path.exists(SAVE_FILE_A):
        print(f"Error: {SAVE_FILE_A} not found!")
        return
        
    print("Sentinel Worlds I: Future Magic - Save Game Inspector")
    print("=" * 50)
    
    # Inspect both save files if they exist
    if os.path.exists(SAVE_FILE_A):
        inspect_save_game(SAVE_FILE_A)
    if os.path.exists(SAVE_FILE_B):
        inspect_save_game(SAVE_FILE_B)

if __name__ == "__main__":
    main()