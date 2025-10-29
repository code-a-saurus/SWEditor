## Sentinel Worlds I: Future Magic save game editor
Version: 0.5b (Beta)

Author: Lee Hutchinson

This script provides a command-line interface for editing save game files
from the 1989 MS-DOS game "Sentinel Worlds I: Future Magic".

The editor can modify:
- Party cash and light energy
- Individual character stats, abilities, and inventory
- Ship software levels

### Usage

You need to provide your own Sentinel Worlds I save game files (gameX.fm where X = A-Z).

**Command-line usage:**
```bash
python3 src/main.py path/to/gamea.fm
```

**Interactive usage:**
```bash
python3 src/main.py
```
Then enter the path when prompted, or just press Enter to use the default location (test_data/).

The editor supports:
- Flexible file paths (absolute, relative, or ~/home paths)
- Any gameX.fm filename (X = A-Z, case-insensitive)
- Automatic file validation and backup creation (.bak files)
- Command-line help: `python3 src/main.py --help`
- Version info: `python3 src/main.py --version`

**Note:** The directory containing your save file must be writable for backups and saving.

### License
This project is licensed under the terms of the GNU General Public License
v3.0. See the LICENSE file for details.