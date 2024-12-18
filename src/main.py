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

def get_crew_addresses():
    """Generate address mappings for all crew members programmatically."""
    crew_addrs = {}
    
    for crew_num in range(1, 6):
        # Get the crew-specific constant prefix (e.g., "CREW1_", "CREW2_", etc)
        prefix = f"CREW{crew_num}_"
        
        # Use globals() to look up constants by constructed name
        crew_addrs[crew_num] = {
            'rank': globals()[f"{prefix}RANK_ADDR"],
            'hp': globals()[f"{prefix}HP_ADDR"],
            'characteristics': {
                'strength': globals()[f"{prefix}STRENGTH_ADDR"],
                'stamina': globals()[f"{prefix}STAMINA_ADDR"],
                'dexterity': globals()[f"{prefix}DEXTERITY_ADDR"],
                'comprehend': globals()[f"{prefix}COMPREHEND_ADDR"],
                'charisma': globals()[f"{prefix}CHARISMA_ADDR"]
            },
            'abilities': {
                'contact': globals()[f"{prefix}CONTACT_ADDR"],
                'edged': globals()[f"{prefix}EDGED_ADDR"],
                'projectile': globals()[f"{prefix}PROJECTILE_ADDR"],
                'blaster': globals()[f"{prefix}BLASTER_ADDR"],
                'tactics': globals()[f"{prefix}TACTICS_ADDR"],
                'recon': globals()[f"{prefix}RECON_ADDR"],
                'gunnery': globals()[f"{prefix}GUNNERY_ADDR"],
                'atv_repair': globals()[f"{prefix}ATV_REPAIR_ADDR"],
                'mining': globals()[f"{prefix}MINING_ADDR"],
                'athletics': globals()[f"{prefix}ATHLETICS_ADDR"],
                'observation': globals()[f"{prefix}OBSERVATION_ADDR"],
                'bribery': globals()[f"{prefix}BRIBERY_ADDR"]
            },
            'equipment': {
                'armor': globals()[f"{prefix}ARMOR_ADDR"],
                'weapon': globals()[f"{prefix}WEAPON_ADDR"],
                'onhand_weapons_start': globals()[f"{prefix}ONHAND_WEAPONS_START"],
                'inventory_start': globals()[f"{prefix}INVENTORY_START"]
            }
        }
    
    return crew_addrs

def load_save_game(filename: str) -> dict:
    """
    Load all save game data from the specified file into a dictionary.
    
    Args:
        filename: Path to the save game file
        
    Returns:
        dict: Populated save game data structure
    
    Raises:
        FileNotFoundError: If save game file doesn't exist
        IOError: If there are problems reading the file
    """
    save_data = initialize_save_data()
    
    with open(filename, 'rb') as f:
        # Load party-wide values
        save_data['party']['cash'] = read_byte(f, PARTY_CASH_ADDR)
        save_data['party']['light_energy'] = read_byte(f, PARTY_LIGHT_ENERGY_ADDR)
        
        # Load ship software values
        save_data['ship']['move'] = read_byte(f, SHIP_MOVE_ADDR)
        save_data['ship']['target'] = read_byte(f, SHIP_TARGET_ADDR)
        save_data['ship']['engine'] = read_byte(f, SHIP_ENGINE_ADDR)
        save_data['ship']['laser'] = read_byte(f, SHIP_LASER_ADDR)
        
        # Define addresses for all crew members
        crew_addrs = get_crew_addresses()
        
        # Load data for each crew member
        for crew_num in range(1, 6):
            addrs = crew_addrs[crew_num]
            
            # Basic stats
            save_data['crew'][crew_num]['rank'] = read_byte(f, addrs['rank'])
            save_data['crew'][crew_num]['hp'] = read_byte(f, addrs['hp'])
            
            # Characteristics
            for stat, addr in addrs['characteristics'].items():
                save_data['crew'][crew_num]['characteristics'][stat] = read_byte(f, addr)
            
            # Abilities
            for ability, addr in addrs['abilities'].items():
                save_data['crew'][crew_num]['abilities'][ability] = read_byte(f, addr)
            
            # Equipment
            save_data['crew'][crew_num]['equipment']['armor'] = read_byte(f, addrs['equipment']['armor'])
            save_data['crew'][crew_num]['equipment']['weapon'] = read_byte(f, addrs['equipment']['weapon'])
            
            # Load onhand weapons (3 consecutive bytes)
            for i in range(3):
                save_data['crew'][crew_num]['equipment']['onhand_weapons'][i] = \
                    read_byte(f, addrs['equipment']['onhand_weapons_start'] + i)
            
            # Load inventory (8 consecutive bytes)
            for i in range(8):
                save_data['crew'][crew_num]['equipment']['inventory'][i] = \
                    read_byte(f, addrs['equipment']['inventory_start'] + i)
    
    return save_data

def print_dictionary(d, indent=0):
    """
    Recursively print a nested dictionary with nice formatting.
    
    Args:
        d: Dictionary to print
        indent: Current indentation level
    """
    for key, value in d.items():
        indent_str = "  " * indent
        if isinstance(value, dict):
            print(f"{indent_str}{key}:")
            print_dictionary(value, indent + 1)
        elif isinstance(value, list):
            print(f"{indent_str}{key}: {value}")
        else:
            print(f"{indent_str}{key}: {value}")

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
    
    try:
        # Load the save game data into our global dictionary
        global save_game_data
        save_game_data = load_save_game(filename)
        app_state['file_loaded'] = True
        
        # Print all values in the dictionary
        print("\nAll Save Game Values:")
        print("---------------------")
        print_dictionary(save_game_data)
            
    except (IOError, FileNotFoundError) as e:
        print(f"\nError loading save file: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        sys.exit(1)
        
    print("\nTest complete. Exiting editor.")

if __name__ == "__main__":
    main()