import os
import sys
from typing import Tuple, List, Dict, Optional

EQUIPMENT_IDS = {
    "weapons": {
        0x00: "Empty",
        0x01: "Laser Pistol",
        0x02: "Laser Rifle",
        0x03: "Plasma Gun",
        0x04: "Heavy Plasma",
        0x05: "Pulse Rifle",
    },
    "armor": {
        0x00: "Empty",
        0x01: "Light Armor",
        0x02: "Medium Armor",
        0x03: "Heavy Armor",
        0x04: "Power Suit",
    }
}

class SaveGameEditor:
    def __init__(self, save_dir: str = "test_data"):
        """Initialize the save game editor with path to save file.
        
        Args:
            save_dir: Directory containing GAMEA.FM save file
        """
        self.save_dir = save_dir
        self.save_file = os.path.join(save_dir, "GAMEA.FM")
        
        # Verify save file exists
        if not os.path.exists(self.save_file):
            raise FileNotFoundError(f"Save file not found in {save_dir}. Ensure GAMEA.FM exists.")

        # Known file offsets
        self.CREDITS_OFFSET = 0x1000
        self.CHARACTER_STATS_BASE = 0x2000
        self.EQUIPMENT_BASE = 0x3000
        
        # Updated character constants
        self.NUM_CHARACTERS = 5
        self.STATS_PER_CHARACTER = 5
        self.EQUIPMENT_SLOTS_PER_CHARACTER = 3

    def read_save_file(self) -> bytearray:
        """Read the save file into memory."""
        with open(self.save_file, 'rb') as f:
            return bytearray(f.read())

    def write_save_file(self, data: bytearray):
        """Write data back to save file."""
        with open(self.save_file, 'wb') as f:
            f.write(data)

    def get_credits(self) -> int:
        """Read current credits from save file."""
        data = self.read_save_file()
        return int.from_bytes(data[self.CREDITS_OFFSET:self.CREDITS_OFFSET + 4], 'little')

    def set_credits(self, amount: int):
        """Set credits to specified amount."""
        data = self.read_save_file()
        data[self.CREDITS_OFFSET:self.CREDITS_OFFSET + 4] = amount.to_bytes(4, 'little')
        self.write_save_file(data)

    def get_character_stats(self, char_index: int) -> Dict[str, int]:
        """Get stats for specified character index."""
        if not 0 <= char_index < self.NUM_CHARACTERS:
            raise ValueError(f"Character index must be between 0 and {self.NUM_CHARACTERS-1}")

        data = self.read_save_file()
        offset = self.CHARACTER_STATS_BASE + (char_index * self.STATS_PER_CHARACTER)
        
        return {
            "strength": data[offset],
            "dexterity": data[offset + 1],
            "intelligence": data[offset + 2],
            "speed": data[offset + 3],
            "health": data[offset + 4]
        }

    def set_character_stats(self, char_index: int, stats: Dict[str, int]):
        """Set stats for specified character."""
        if not 0 <= char_index < self.NUM_CHARACTERS:
            raise ValueError(f"Character index must be between 0 and {self.NUM_CHARACTERS-1}")

        data = self.read_save_file()
        offset = self.CHARACTER_STATS_BASE + (char_index * self.STATS_PER_CHARACTER)
        
        data[offset] = stats["strength"]
        data[offset + 1] = stats["dexterity"]
        data[offset + 2] = stats["intelligence"]
        data[offset + 3] = stats["speed"]
        data[offset + 4] = stats["health"]
        
        self.write_save_file(data)

    def get_equipment(self, char_index: int) -> Dict[str, List[str]]:
        """Get equipment for specified character."""
        if not 0 <= char_index < self.NUM_CHARACTERS:
            raise ValueError(f"Character index must be between 0 and {self.NUM_CHARACTERS-1}")

        data = self.read_save_file()
        offset = self.EQUIPMENT_BASE + (char_index * self.EQUIPMENT_SLOTS_PER_CHARACTER)
        
        equipment = {
            "weapons": [
                EQUIPMENT_IDS["weapons"].get(data[offset], "Unknown"),
                EQUIPMENT_IDS["weapons"].get(data[offset + 1], "Unknown")
            ],
            "armor": [
                EQUIPMENT_IDS["armor"].get(data[offset + 2], "Unknown")
            ]
        }
        return equipment

    def set_equipment(self, char_index: int, slot_type: str, slot_index: int, item_id: int):
        """Set equipment for specified character slot."""
        if not 0 <= char_index < self.NUM_CHARACTERS:
            raise ValueError(f"Character index must be between 0 and {self.NUM_CHARACTERS-1}")
            
        if slot_type not in ["weapons", "armor"]:
            raise ValueError("Slot type must be 'weapons' or 'armor'")
            
        if slot_type == "weapons" and not 0 <= slot_index < 2:
            raise ValueError("Weapon slot index must be 0 or 1")
        elif slot_type == "armor" and slot_index != 0:
            raise ValueError("Armor slot index must be 0")
            
        # Validate item ID exists
        equipment_type = EQUIPMENT_IDS[slot_type]
        if item_id not in equipment_type:
            raise ValueError(f"Invalid {slot_type} ID: {item_id}")

        data = self.read_save_file()
        base_offset = self.EQUIPMENT_BASE + (char_index * self.EQUIPMENT_SLOTS_PER_CHARACTER)
        
        # Calculate slot offset
        if slot_type == "weapons":
            offset = base_offset + slot_index
        else:  # armor
            offset = base_offset + 2  # Single armor slot at index 2
            
        data[offset] = item_id
        self.write_save_file(data)

def display_menu():
    """Display the main menu options."""
    print("\nSentinel Worlds I: Future Magic - Save Game Editor")
    print("1. View/Edit Credits")
    print("2. View/Edit Character Stats")
    print("3. View/Edit Equipment")
    print("4. Exit")
    return input("Select an option (1-4): ")

def edit_credits(editor: SaveGameEditor):
    """Handle credits editing interface."""
    current_credits = editor.get_credits()
    print(f"\nCurrent Credits: {current_credits}")
    new_credits = input("Enter new credit amount (or press Enter to keep current): ")
    
    if new_credits.strip():
        try:
            editor.set_credits(int(new_credits))
            print(f"Credits updated to: {new_credits}")
        except ValueError:
            print("Invalid input. Please enter a number.")

def edit_character_stats(editor: SaveGameEditor):
    """Handle character stats editing interface."""
    char_index = int(input(f"\nEnter character index (0-{editor.NUM_CHARACTERS-1}): "))
    
    try:
        stats = editor.get_character_stats(char_index)
        print(f"\nCurrent stats for Character {char_index}:")
        for stat, value in stats.items():
            print(f"{stat.capitalize()}: {value}")
            
        print("\nEnter new values (or press Enter to keep current):")
        new_stats = {}
        for stat in stats:
            new_value = input(f"{stat.capitalize()}: ")
            new_stats[stat] = int(new_value) if new_value.strip() else stats[stat]
            
        editor.set_character_stats(char_index, new_stats)
        print("Stats updated successfully!")
        
    except ValueError as e:
        print(f"Error: {e}")

def edit_equipment(editor: SaveGameEditor):
    """Handle equipment editing interface."""
    char_index = int(input(f"\nEnter character index (0-{editor.NUM_CHARACTERS-1}): "))
    
    try:
        equipment = editor.get_equipment(char_index)
        print(f"\nCurrent equipment for Character {char_index}:")
        print("Weapons:")
        for i, weapon in enumerate(equipment["weapons"]):
            print(f"  Slot {i}: {weapon}")
        print("Armor:")
        print(f"  Slot 0: {equipment['armor'][0]}")
            
        # Equipment editing menu
        print("\nEdit equipment:")
        print("1. Edit Weapons")
        print("2. Edit Armor")
        choice = input("Select option (1-2): ")
        
        if choice == "1":
            slot_type = "weapons"
            print("\nAvailable weapons:")
        elif choice == "2":
            slot_type = "armor"
            print("\nAvailable armor:")
        else:
            print("Invalid choice")
            return
            
        # Display available equipment
        for item_id, name in EQUIPMENT_IDS[slot_type].items():
            print(f"{item_id}: {name}")
            
        if slot_type == "weapons":
            slot_index = int(input("Enter weapon slot index (0-1): "))
        else:
            slot_index = 0
            print("Using armor slot 0 (only slot available)")
            
        item_id = int(input("Enter item ID: "))
        
        editor.set_equipment(char_index, slot_type, slot_index, item_id)
        print("Equipment updated successfully!")
        
    except ValueError as e:
        print(f"Error: {e}")

def main():
    # Get save directory from command line if provided, otherwise use default
    save_dir = sys.argv[1] if len(sys.argv) > 1 else "test_data"
    
    try:
        editor = SaveGameEditor(save_dir)
        
        while True:
            choice = display_menu()
            
            if choice == "1":
                edit_credits(editor)
            elif choice == "2":
                edit_character_stats(editor)
            elif choice == "3":
                edit_equipment(editor)
            elif choice == "4":
                print("Exiting...")
                break
            else:
                print("Invalid choice. Please select 1-4.")
                
    except FileNotFoundError as e:
        print(f"Error: {e}")
        print(f"Please ensure GAMEA.FM exists in the specified directory: {save_dir}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()