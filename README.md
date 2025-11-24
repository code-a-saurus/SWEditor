## Sentinel Worlds I: Future Magic save game editor
Version: 0.7b (Beta)

Author: Kinda Lee Hutchinson but really Claude.ai Code

This editor provides both a command-line interface (CLI) and a graphical user interface (GUI)
for editing save game files from the 1989 MS-DOS game "Sentinel Worlds I: Future Magic".

The editor can modify:
- Party cash and light energy
- Individual character stats, abilities, and inventory
- Ship software levels

### Installation

**Option 1: Install with pip (Recommended)**
```bash
# From the project directory
pip install .

# Or install directly from your Git repository
pip install git+https://github.com/code-a-saurus/SWEditor.git
```

After installation, you can run either version from anywhere:
```bash
# Command-line interface (text-based menu)
sw-editor path/to/gamea.fm

# Graphical interface (window-based with mouse navigation)
sw-editor-gui
```

**Option 2: Run directly from source**
```bash
# Command-line interface
python3 src/main.py path/to/gamea.fm

# Graphical interface
python3 src/gui.py
```

### Usage

You need to provide your own Sentinel Worlds I save game files (gameX.fm where X = A-Z).

#### Graphical Interface (Recommended for most users)

Launch the GUI version for an intuitive, mouse-driven experience:
```bash
sw-editor-gui
# or if running from source:
python3 src/gui.py
```

**GUI Features:**
- Tree-based navigation of all save game elements
- Visual forms for editing with labeled fields and dropdown menus
- Real-time unsaved changes indicator
- Equipment selection via searchable dropdown lists
- Built-in validation with clear error messages
- Keyboard shortcuts (Cmd+O to open, Cmd+S to save, Cmd+Q to quit)
- Automatic backup creation before any changes

Simply use File → Open Save File to load a save game, navigate the tree on the left to select
what to edit, make your changes in the form on the right, and use File → Save (or Cmd+S) to save.

#### Command-Line Interface

For advanced users or automation, use the text-based CLI:

**With file path:**
```bash
sw-editor path/to/gamea.fm
# or if running from source:
python3 src/main.py path/to/gamea.fm
```

**Interactive mode:**
```bash
sw-editor
# or if running from source:
python3 src/main.py
```
Then enter the path when prompted, or just press Enter to use the default location (test_data/).

**CLI Features:**
- Flexible file paths (absolute, relative, or ~/home paths)
- Any gameX.fm filename (X = A-Z, case-insensitive)
- Automatic file validation and backup creation (.bak files)
- Command-line help: `sw-editor --help`
- Version info: `sw-editor --version`
- Menu-driven navigation through keyboard input

**Note:** The directory containing your save file must be writable for backups and saving.

### Uninstallation

If you installed with pip:
```bash
pip uninstall sentinel-worlds-editor
```

### License
This project is licensed under the terms of the GNU General Public License
v3.0. See the LICENSE file for details.