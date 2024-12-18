#!/usr/bin/env python3
"""
Sentinel Worlds I: Future Magic Save Game Editor
Version: 1.0
Author: Lee Hutchinson

This script provides a command-line interface for editing save game files
from the 1989 MS-DOS game "Sentinel Worlds I: Future Magic".

The editor can modify:
- Party cash and light energy
- Individual character stats, abilities, and inventory
- Ship software levels

Usage:
    Run the script and follow the interactive prompts to edit either
    GAMEA.FM or GAMEB.FM save files.
"""

import os
import sys
from typing import Optional, Dict, List
from sw_constants import * # Imports all our game constants

# Constants for file operations
SAVE_FILE_A = "test_data/gamea.fm"
SAVE_FILE_B = "test_data/gameb.fm"

# Global state for save game data
save_game_data = {}

# Global state for application
app_state = {
    'current_file': None,  # Will hold 'A' or 'B' once user selects
    'has_changes': False,  # Track if there are unsaved changes
    'file_loaded': False   # Track if we've successfully loaded a file
}

def get_save_file_choice() -> Optional[str]:
    """Prompt user to select which save file to edit."""
    print("\nSelect save file to edit:")
    print("A) GAMEA.FM")
    print("B) GAMEB.FM")
    print("Any other key to quit")
    
    choice = input("\nChoice: ").upper()
    
    if choice == 'A':
        return SAVE_FILE_A
    elif choice == 'B':
        return SAVE_FILE_B
    else:
        return None

def read_byte(file_handle, address: int) -> int:
    """
    Read a single byte from a specific address in the save game file.
    
    Args:
        file_handle: An open file handle in binary read mode
        address: The hex address to read from
        
    Returns:
        int: The byte value at that address converted to integer
    """
    file_handle.seek(address)
    return int.from_bytes(file_handle.read(1), byteorder='little')

def initialize_save_data() -> dict:
    """
    Create the initial save_game_data dictionary structure.
    
    Returns:
        dict: Empty save game data structure with all required keys
    """
    save_data = {
        'party': {
            'cash': 0,
            'light_energy': 0
        },
        'ship': {
            'move': 0,
            'target': 0,
            'engine': 0,
            'laser': 0
        },
        'crew': {}
    }
    
    # Create identical structure for all 5 crew members
    for crew_num in range(1, 6):
        save_data['crew'][crew_num] = {
            'rank': 0,
            'hp': 0,
            'characteristics': {
                'strength': 0,
                'stamina': 0,
                'dexterity': 0,
                'comprehend': 0,
                'charisma': 0
            },
            'abilities': {
                'contact': 0,
                'edged': 0,
                'projectile': 0,
                'blaster': 0,
                'tactics': 0,
                'recon': 0,
                'gunnery': 0,
                'atv_repair': 0,
                'mining': 0,
                'athletics': 0,
                'observation': 0,
                'bribery': 0
            },
            'equipment': {
                'armor': 0,
                'weapon': 0,
                'onhand_weapons': [0, 0, 0],
                'inventory': [0, 0, 0, 0, 0, 0, 0, 0]
            }
        }
    
    return save_data

def main():
    """Main entry point for the save game editor."""
    print("Sentinel Worlds I: Future Magic - Save Game Editor")
    print("-----------------------------------------------")
    
    filename = get_save_file_choice()
    if not filename:
        print("\nExiting editor.")
        sys.exit(0)
        
    if not os.path.exists(filename):
        print(f"\nError: Save file {filename} not found!")
        sys.exit(1)
        
    app_state['current_file'] = 'A' if filename == SAVE_FILE_A else 'B'
    print(f"\nOpening {os.path.basename(filename)}...")
    
    # TODO: Here's where we'll add code to load the save file
    # and display the main menu

if __name__ == "__main__":
    main()