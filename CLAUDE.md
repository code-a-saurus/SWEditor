# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a save game editor for "Sentinel Worlds I: Future Magic" (1989 MS-DOS game). It provides both a CLI and GUI for modifying binary save files (gameX.fm where X = A-Z). The editor reads/writes specific hex addresses in the binary save file format to modify party cash, light energy, ship software, and crew member stats/equipment/inventory.

**License:** GPL-3.0-or-later (all new code must include GPL license header)

## Development Environment

**Python version:** 3.13.1 (minimum 3.10)
**Virtual environment:** Project uses a venv at `./venv/`
**Always use venv Python:** `./venv/bin/python3` for all operations

### Installation & Setup

```bash
# Install the package locally in development mode
./venv/bin/pip install -e .

# Install with dev dependencies
./venv/bin/pip install -e ".[dev]"
```

## Running the Application

```bash
# GUI version (recommended for users)
./venv/bin/sw-editor-gui
# or: ./venv/bin/python3 src/gui.py

# CLI version (text-based menu)
./venv/bin/sw-editor path/to/gamea.fm
# or: ./venv/bin/python3 src/main.py path/to/gamea.fm

# Version check
./venv/bin/sw-editor --version
```

## Testing

```bash
# Run test suite (currently no actual pytest tests exist)
./venv/bin/python3 -m pytest tests/ -v

# Run the inspector diagnostic tool (displays all save game values)
./venv/bin/python3 tests/test_inspector.py [path/to/savefile.fm]
# If no path provided, searches test_data/ directory for .fm files
```

**Note:** `tests/test_inspector.py` is a diagnostic utility, not a pytest test. There are currently no unit tests.

## Architecture

### Binary Save File Structure

The core functionality revolves around reading and writing specific hex addresses in the binary save files:

- **Save files:** `gameX.fm` files (~12KB binary files)
- **Validation:** Files must contain "Sentinel" signature at address 0x3181
- **Automatic backups:** Creates `.bak` files before any modifications

### Module Organization

**src/sw_constants.py**
- Defines all hex memory addresses for save file data (party, ship, 5 crew members)
- Defines game item constants (weapons, armor, inventory items as hex codes)
- Defines max value limits (MAX_CASH, MAX_HP, MAX_STAT, etc.)
- Each crew member has addresses for: name, HP, rank, characteristics (5), abilities (12), equipment (armor, weapon, 3 onhand weapons, 8 inventory slots)

**src/inventory_constants.py**
- Maps item hex codes to human-readable names (ITEM_NAMES dict)
- Defines valid item sets (VALID_ARMOR, VALID_WEAPONS, VALID_INVENTORY)

**src/main.py** (1189 lines)
- Core save file I/O operations using binary read/write
- Data structure management (nested dicts for party/ship/crew)
- CLI menu system for editing
- Global state in `save_game_data` dict and `app_state` dict

Key functions:
- `read_bytes(file_handle, address, num_bytes=1)` - Read from hex address (little-endian)
- `write_bytes(file_handle, address, value, num_bytes=1)` - Write to hex address (little-endian)
- `read_string(file_handle, address, length)` - Read ASCII string
- `write_string(file_handle, address, value, length)` - Write ASCII string (space-padded)
- `load_save_game(filename)` - Read entire save file into `save_game_data` dict
- `save_game(filename)` - Write `save_game_data` dict back to binary file
- `validate_save_file(filepath)` - Check file validity (exists, readable, correct size/signature, writable directory)

**src/gui.py** (710 lines)
- Tkinter-based GUI using ttk widgets
- Tree navigation on left, editing forms on right
- Real-time unsaved changes tracking
- Dropdown menus for equipment selection
- Uses same backend functions from main.py for file I/O

### Data Flow

1. **Loading:** Binary file → `load_save_game()` → nested dict structure in `save_game_data`
2. **Editing:** User modifies values in `save_game_data` dict via CLI menus or GUI forms
3. **Saving:** `save_game()` writes entire `save_game_data` dict back to binary file at specific hex addresses

### Dual Import Pattern

Both main.py and gui.py use try/except for imports to support:
- Pip-installed execution: `from src.module import ...`
- Direct execution: `from module import ...`

This pattern must be maintained in all new modules.

## Editable Game Elements

The save game contains data for a party of 5 crew members. All addresses are defined in sw_constants.py.

**Party-Wide Values:**
1. Party's current cash (3-byte value, max 655,359)
2. Party's light energy (1-byte value, max 254)

**Ship Software (4 values):**
1. Move
2. Target
3. Engine
4. Laser

**Per Crew Member (5 crew members, each with identical structure):**

1. **Name** - 15-character ASCII string (space-padded)
2. **Rank** - Single byte value
3. **Hit Points** - Single byte (max 125)
4. **Characteristics (5 stats, each max 254):**
   - Strength
   - Stamina
   - Dexterity
   - Comprehend
   - Charisma
5. **Abilities (12 skills, each max 254):**
   - Contact
   - Edged
   - Projectile
   - Blaster
   - Tactics
   - Recon
   - Gunnery
   - ATV Repair
   - Mining
   - Athletics
   - Observation
   - Bribery
6. **Equipment:**
   - Equipped armor (1 slot, hex code from VALID_ARMOR)
   - Equipped weapon (1 slot, hex code from VALID_WEAPONS)
   - On-hand weapons (3 slots, hex codes from VALID_WEAPONS)
   - Inventory (8 slots, hex codes from VALID_INVENTORY)

All equipment uses hex codes (0x00-0xFF) mapped to item names in ITEM_NAMES dict. Empty slots use 0xFF.

## Critical Constraints

### Binary File Format
- All integer values are stored in **little-endian** format
- Multi-byte reads/writes must use little-endian byte order
- Character names are fixed-length ASCII strings (15 bytes), space-padded
- Empty inventory/equipment slots use 0xFF

### Save File Safety
- Always validate file before loading (signature check at 0x3181)
- Always create .bak backup before any modifications
- Directory must be writable (checked during validation)
- File size must be 1KB-16KB

### Item Code Validation
- Armor codes must be in VALID_ARMOR set
- Weapon codes must be in VALID_WEAPONS set
- Inventory items must be in VALID_INVENTORY set
- Use ITEM_NAMES dict for human-readable display

## Git Workflow

**Main repository:** Self-hosted Gitea at `ssh://teacup.bigdinosaur.lan:2222/BigDino/SWEditor.git`
**User preference:** Use Gitea web interface when possible for git operations
**VS Code integration:** User has VS Code git hooks configured

## Package Distribution

The project is distributed as a pip-installable package (not published to PyPI):

```bash
# Install from local directory
pip install .

# Install from git repository
pip install git+ssh://teacup.bigdinosaur.lan:2222/BigDino/SWEditor.git
```

Creates two executable commands:
- `sw-editor` → CLI interface
- `sw-editor-gui` → GUI interface

## Working with the User

**User Background:**
- Expert sysadmin but beginner coder
- Define new terms and programming concepts clearly when introduced
- Has multiple original SW1 save games for testing in test_data/ directory

**Teaching Methodology:**
- Focus on teaching core concepts before implementing code
- Explain the "why" behind each programming concept before showing code examples
- Wait for user understanding before proceeding to implementation
- Break down save editor development into clear learning steps
- Guide user to discover solutions through questions and hints rather than providing complete code
- Only offer specific code suggestions when user is stuck
- Ask for user feedback on comprehension regularly to adjust teaching pace and depth

**Code Presentation:**
- Use artifacts only for complete, working code examples after concepts are understood
- When implementing, explain the approach first, then show the code

**Tool Preferences:**
- Visual Studio Code with git hooks configured
- Prefer Gitea web interface instructions for git operations when applicable
- Note when VS Code can handle git operations directly

## Important Files

- **TASKS.todo.md** - History of completed work and implementation notes
- **SW1_hex_values.txt** - Complete table of all hex addresses (reference document)
- **pyproject.toml** - Package configuration, entry points, dependencies
- **test_data/** - Directory for user's save files (gitignored)
