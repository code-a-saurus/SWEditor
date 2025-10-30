#!/usr/bin/env python3
"""
Sentinel Worlds I: Future Magic Save Game Inspector
A diagnostic tool that reads and displays all values from a save game file

Usage:
    python3 tests/test_inspector.py [path/to/savefile.fm]

    If no path is provided, it will look for save files in test_data/

This file is part of a project licensed under the GNU General Public License v3.
See the LICENSE file in the root directory or <https://www.gnu.org/licenses/>.

"""

import os
import sys
import argparse
import glob
import re
from typing import Dict, Any
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

# Handle imports for both pip-installed and direct execution
try:
    from src.main import load_save_game
    from src.inventory_constants import ITEM_NAMES
except ModuleNotFoundError:
    # Add src to path if running directly
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))
    from main import load_save_game
    from inventory_constants import ITEM_NAMES

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
    parser = argparse.ArgumentParser(
        description='Inspect Sentinel Worlds I: Future Magic save game files',
        epilog='If no file is specified, will search test_data/ for .fm files'
    )
    parser.add_argument(
        'files',
        nargs='*',
        help='Path(s) to save file(s) to inspect (gameX.fm where X = A-Z)'
    )

    args = parser.parse_args()

    print("Sentinel Worlds I: Future Magic - Save Game Inspector")
    print("=" * 50)

    # Get files to inspect
    files_to_inspect = []

    if args.files:
        # Use files specified on command line
        files_to_inspect = args.files
    else:
        # Look for .fm files in test_data/
        test_data_dir = os.path.join(os.path.dirname(__file__), '..', 'test_data')
        if os.path.exists(test_data_dir):
            # Find both .fm and .FM files
            all_files = []
            all_files.extend(glob.glob(os.path.join(test_data_dir, '*.fm')))
            all_files.extend(glob.glob(os.path.join(test_data_dir, '*.FM')))

            # Exclude .bak backup files and filter for valid save file pattern (gameX.fm where X=A-Z)
            files_to_inspect = []
            for f in all_files:
                basename = os.path.basename(f)
                # Match gameX.fm pattern (X = single letter A-Z, case-insensitive) and exclude .bak files
                if re.match(r'^game[a-z]\.fm$', basename, re.IGNORECASE) and not f.endswith('.bak'):
                    files_to_inspect.append(f)

        if not files_to_inspect:
            print("\nNo save files found in test_data/")
            print("Usage: python3 tests/test_inspector.py [path/to/savefile.fm]")
            return

    # Inspect each file
    for filepath in files_to_inspect:
        if not os.path.exists(filepath):
            print(f"\nError: File not found: {filepath}")
            continue

        inspect_save_game(filepath)

if __name__ == "__main__":
    main()