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

def read_multi_bytes(file_handle, address: int, num_bytes: int) -> int:
    """
    Read multiple bytes from a specific address in little-endian format.
    
    Args:
        file_handle: An open file handle in binary read mode
        address: The starting hex address to read from
        num_bytes: Number of consecutive bytes to read
        
    Returns:
        int: The combined value of the bytes as an integer
        
    Raises:
        IOError: If there are problems reading from the file
        ValueError: If num_bytes is less than 1
    """
    if num_bytes < 1:
        raise ValueError("Number of bytes to read must be positive")
        
    # Seek to the starting address
    file_handle.seek(address)
    
    # Read the specified number of bytes
    bytes_data = file_handle.read(num_bytes)
    
    # Verify we got all the bytes we expected
    if len(bytes_data) != num_bytes:
        raise IOError(f"Could not read {num_bytes} bytes from address {hex(address)}")
    
    # Convert the bytes to an integer using little-endian format
    return int.from_bytes(bytes_data, byteorder='little')

def write_byte(file_handle, address: int, value: int):
    """
    Write a single byte to a specific address in the save game file.
    
    Args:
        file_handle: An open file handle in binary write mode
        address: The hex address to write to
        value: The value to write (must be 0-255)
        
    Raises:
        ValueError: If value is outside valid byte range
    """
    if not 0 <= value <= 255:
        raise ValueError(f"Byte value {value} at address {hex(address)} is outside valid range (0-255)")
    
    # TODO: Future improvement - compare value against current byte on disk
    # to determine if write is actually needed
    
    file_handle.seek(address)
    file_handle.write(bytes([value]))

def write_multi_bytes(file_handle, address: int, value: int, num_bytes: int):
    """
    Write multiple bytes to a specific address in little-endian format.
    
    Args:
        file_handle: An open file handle in binary write mode
        address: The hex address to write to
        value: The integer value to write
        num_bytes: Number of bytes to write
        
    Raises:
        ValueError: If value won't fit in num_bytes or if num_bytes < 1
    """
    if num_bytes < 1:
        raise ValueError("Number of bytes to write must be positive")
        
    # Calculate maximum value that can fit in num_bytes
    max_value = (256 ** num_bytes) - 1
    
    if not 0 <= value <= max_value:
        raise ValueError(f"Value {value} is too large for {num_bytes} bytes (max: {max_value})")
    
    # Convert value to bytes in little-endian format
    value_bytes = value.to_bytes(num_bytes, byteorder='little')
    
    # Seek to address and write bytes
    file_handle.seek(address)
    file_handle.write(value_bytes)

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
                'hp': {
                    'start': globals()[f"{prefix}HP_START"],
                    'length': globals()[f"{prefix}HP_LENGTH"]
                },
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
        save_data['party']['cash'] = read_multi_bytes(f, PARTY_CASH_ADDR, PARTY_CASH_LENGTH)
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
            save_data['crew'][crew_num]['hp'] = read_multi_bytes(f, 
                addrs['hp']['start'], 
                addrs['hp']['length']
            )
            
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

def save_game(filename: str) -> bool:
    """
    Write all values from save_game_data back to the save file.
    
    Args:
        filename: Path to the save game file
        
    Returns:
        bool: True if save successful, False otherwise
        
    Raises:
        IOError: If there are problems writing to the file
    """
    try:
        with open(filename, 'rb+') as f:  # Note: binary read+write mode
            # Save party-wide values
            write_multi_bytes(f, PARTY_CASH_ADDR, save_game_data['party']['cash'], PARTY_CASH_LENGTH)
            write_byte(f, PARTY_LIGHT_ENERGY_ADDR, save_game_data['party']['light_energy'])
            
            # Save ship software values
            write_byte(f, SHIP_MOVE_ADDR, save_game_data['ship']['move'])
            write_byte(f, SHIP_TARGET_ADDR, save_game_data['ship']['target'])
            write_byte(f, SHIP_ENGINE_ADDR, save_game_data['ship']['engine'])
            write_byte(f, SHIP_LASER_ADDR, save_game_data['ship']['laser'])
            
            # Get crew addresses mapping
            crew_addrs = get_crew_addresses()
            
            # Save data for each crew member
            for crew_num in range(1, 6):
                addrs = crew_addrs[crew_num]
                crew = save_game_data['crew'][crew_num]
                
                # Basic stats
                write_byte(f, addrs['rank'], crew['rank'])
                write_multi_bytes(f, addrs['hp']['start'], crew['hp'], crew_addrs[crew_num]['hp']['length'])
                
                # Characteristics
                for stat, addr in addrs['characteristics'].items():
                    write_byte(f, addr, crew['characteristics'][stat])
                
                # Abilities
                for ability, addr in addrs['abilities'].items():
                    write_byte(f, addr, crew['abilities'][ability])
                
                # Equipment
                write_byte(f, addrs['equipment']['armor'], crew['equipment']['armor'])
                write_byte(f, addrs['equipment']['weapon'], crew['equipment']['weapon'])
                
                # Save onhand weapons (3 consecutive bytes)
                for i in range(3):
                    write_byte(f, addrs['equipment']['onhand_weapons_start'] + i,
                             crew['equipment']['onhand_weapons'][i])
                
                # Save inventory (8 consecutive bytes)
                for i in range(8):
                    write_byte(f, addrs['equipment']['inventory_start'] + i,
                             crew['equipment']['inventory'][i])
                             
        app_state['has_changes'] = False  # Clear the changes flag
        return True
        
    except (IOError, ValueError) as e:
        print(f"\nError saving game: {e}")
        return False

def display_main_menu():
    """Display the main menu options to the user."""
    print("\nMain Menu:")
    print("1) Edit party cash")
    print("2) Edit party light energy")
    print("3) Edit ship software")
    print("4) Edit party member stats")
    if app_state['has_changes']:
        print("W) (W)rite pending changes to disk")
    print("Q) (Q)uit")

def handle_main_menu() -> bool:
    """
    Handle user input for the main menu.
    
    Returns:
        bool: False if the user wants to quit, True to continue
    """
    choice = input("\nEnter choice: ").upper()
    
    if choice == 'Q':
        if app_state['has_changes']:
            confirm = input("You have unsaved changes. Really quit? (y/N): ").upper()
            if confirm != 'Y':
                return True
        return False
    elif choice == 'W' and app_state['has_changes']:
        filename = SAVE_FILE_A if app_state['current_file'] == 'A' else SAVE_FILE_B
        if save_game(filename):
            print("\nChanges saved successfully!")
        return True
    elif choice == '1':
        edit_party_cash()
        return True
    elif choice == '2':
        # TODO: Implement edit light energy
        print("\nEditing light energy not yet implemented!")
        return True
    elif choice == '3':
        # TODO: Implement edit ship software
        print("\nEditing ship software not yet implemented!")
        return True
    elif choice == '4':
        # TODO: Implement edit party member stats
        print("\nEditing party member stats not yet implemented!")
        return True
    else:
        print("\nInvalid choice!")
        return True

def edit_party_cash() -> None:
    """
    Edit the party's current cash value.
    Handles input validation and updates the changes flag if modified.
    """
    current_cash = save_game_data['party']['cash']
    print(f"\nCurrent party cash: {current_cash}")
    
    while True:
        try:
            new_cash = input(f"Enter new cash value (1-{MAX_CASH}) or press Enter to keep current: ")
            
            # Handle empty input (keep current value)
            if not new_cash:
                print("Keeping current value.")
                return
                
            # Convert and validate input
            new_cash = int(new_cash)
            if not 1 <= new_cash <= MAX_CASH:
                print(f"Error: Value must be between 1 and {MAX_CASH}")
                continue
                
            # Only update if value actually changed
            if new_cash != current_cash:
                save_game_data['party']['cash'] = new_cash
                app_state['has_changes'] = True
                print(f"Cash updated to: {new_cash}")
            else:
                print("Value unchanged.")
            return
            
        except ValueError:
            print("Error: Please enter a valid number")

def main():
    """Main entry point for the save game editor."""
    print("Sentinel Worlds I: Future Magic - Save Game Editor")
    print("-----------------------------------------------")
    
    filename = get_save_file_choice()
    if not filename:
        print("\nExiting.")
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
        
        # Enter main menu loop
        while True:
            display_main_menu()
            if not handle_main_menu():
                break
            
    except (IOError, FileNotFoundError) as e:
        print(f"\nError loading save file: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        sys.exit(1)
        
    print("\nExiting.")
    
if __name__ == "__main__":
    main()