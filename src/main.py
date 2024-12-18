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