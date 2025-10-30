## Sentinel Worlds I: Future Magic save game editor
Version: 0.5b (Beta)

Author: Lee Hutchinson

This script provides a command-line interface for editing save game files
from the 1989 MS-DOS game "Sentinel Worlds I: Future Magic".

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

After installation, you can run the editor from anywhere:
```bash
sw-editor path/to/gamea.fm
```

**Option 2: Run directly from source**
```bash
python3 src/main.py path/to/gamea.fm
```

### Usage

You need to provide your own Sentinel Worlds I save game files (gameX.fm where X = A-Z).

**Command-line usage:**
```bash
sw-editor path/to/gamea.fm
# or if running from source:
python3 src/main.py path/to/gamea.fm
```

**Interactive usage:**
```bash
sw-editor
# or if running from source:
python3 src/main.py
```
Then enter the path when prompted, or just press Enter to use the default location (test_data/).

**Features:**
- Flexible file paths (absolute, relative, or ~/home paths)
- Any gameX.fm filename (X = A-Z, case-insensitive)
- Automatic file validation and backup creation (.bak files)
- Command-line help: `sw-editor --help`
- Version info: `sw-editor --version`

**Note:** The directory containing your save file must be writable for backups and saving.

### Uninstallation

If you installed with pip:
```bash
pip uninstall sentinel-worlds-editor
```

### License
This project is licensed under the terms of the GNU General Public License
v3.0. See the LICENSE file for details.