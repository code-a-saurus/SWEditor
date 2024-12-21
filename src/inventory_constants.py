"""
Sentinel Worlds I save game inventory constants and lookup tables.
This module provides name lookups and validation sets for equipment editing.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
"""

from sw_constants import *

def format_item_name(constant_name: str) -> str:
    """Convert a constant name like 'NEUTRON_GUN' to 'Neutron Gun'."""
    # Remove common prefixes if they exist
    name = constant_name.replace('ITEM_', '').replace('WEAPON_', '').replace('ARMOR_', '')
    # Replace underscores with spaces and capitalize words
    return ' '.join(word.capitalize() for word in name.split('_'))

# Create reverse lookup dictionary for all items
ITEM_NAMES = {
    # Special case for empty slot
    EMPTY_SLOT: "Empty Slot",
    
    # Miscellaneous items
    BURBULATOR: format_item_name('BURBULATOR'),
    EA_PASSCARD: format_item_name('EA_PASSCARD'),
    TRINOCULARS: format_item_name('TRINOCULARS'),
    ARISIAN_LENS: format_item_name('ARISIAN_LENS'),
    ENERGY_BALL: format_item_name('ENERGY_BALL'),
    BOOK: format_item_name('BOOK'),
    HOLOPHONES: format_item_name('HOLOPHONES'),
    VAX_GRAPHER: format_item_name('VAX_GRAPHER'),
    ANTIQUE_YOYO: format_item_name('ANTIQUE_YOYO'),
    CRYOSCOPE: format_item_name('CRYOSCOPE'),
    CYBERDISK: format_item_name('CYBERDISK'),
    SZART_NEEDLE: format_item_name('SZART_NEEDLE'),
    KNARLYBAR: format_item_name('KNARLYBAR'),
    TESSELATOR: format_item_name('TESSELATOR'),
    NANOBOT: format_item_name('NANOBOT'),
    MARK_V_TENG: format_item_name('MARK_V_TENG'),
    VADROXON: format_item_name('VADROXON'),
    
    # Natural weapons
    HANDS: format_item_name('HANDS'),
    CLAWS: format_item_name('CLAWS'),
    TEETH: format_item_name('TEETH'),
    THRASHER: format_item_name('THRASHER'),
    ACID_BREATH: format_item_name('ACID_BREATH'),
    
    # Melee weapons
    POWERFIST: format_item_name('POWERFIST'),
    SONIC_MACE: format_item_name('SONIC_MACE'),
    GYRO_PIKE: format_item_name('GYRO_PIKE'),
    NEURON_FLAIL: format_item_name('NEURON_FLAIL'),
    DAGGER: format_item_name('DAGGER'),
    CRYO_CUTLAS: format_item_name('CRYO_CUTLAS'),
    POWER_AXE: format_item_name('POWER_AXE'),
    ENERGY_BLADE: format_item_name('ENERGY_BLADE'),
    EDGE_SPINNER: format_item_name('EDGE_SPINNER'),
    
    # Projectile weapons
    AUTO_PISTOL: format_item_name('AUTO_PISTOL'),
    SHOTGUN: format_item_name('SHOTGUN'),
    HYPERUZI: format_item_name('HYPERUZI'),
    AK_4700: format_item_name('AK_4700'),
    GAUSS_RIFLE: format_item_name('GAUSS_RIFLE'),
    
    # Energy weapons
    THERMOCASTER: format_item_name('THERMOCASTER'),
    HAND_LASER: format_item_name('HAND_LASER'),
    LR_LASER: format_item_name('LR_LASER'),
    PLASMA_GUN: format_item_name('PLASMA_GUN'),
    NEUTRON_GUN: format_item_name('NEUTRON_GUN'),
    NERF_CANNON: format_item_name('NERF_CANNON'),
        
    # Armor
    MYSTERIOUS_ARMOR: format_item_name('MYSTERIOUS_ARMOR'),
    ANCIENT_ARMOR: format_item_name('ANCIENT_ARMOR'),
    UNIFORM: format_item_name('UNIFORM'),
    FLIGHT_JACKET: format_item_name('FLIGHT_JACKET'),
    STEEL_MESH: format_item_name('STEEL_MESH'),
    FLAK_JACKET: format_item_name('FLAK_JACKET'),
    LASER_REFLEC: format_item_name('LASER_REFLEC'),
    COMBAT_ARMOR: format_item_name('COMBAT_ARMOR'),
    THICK_SKIN: format_item_name('THICK_SKIN'),
    ROUGH_SKIN: format_item_name('ROUGH_SKIN'),
    THICK_FUR: format_item_name('THICK_FUR'),
    CARBON_ARMOR: format_item_name('CARBON_ARMOR'),
    CIVILIAN_CLOTHES: format_item_name('CIVILIAN_CLOTHES'),
    SPECIAL: format_item_name('SPECIAL'),
    KEVLAR_SUIT: format_item_name('KEVLAR_SUIT'),
    
    # Ammunition and power cells
    AUTO_CLIP: format_item_name('AUTO_CLIP'),
    SHOTGUN_PACK: format_item_name('SHOTGUN_PACK'),
    HYPERUZI_MAG: format_item_name('HYPERUZI_MAG'),
    GAUSS_RIFLE_MAG: format_item_name('GAUSS_RIFLE_MAG'),
    AK_4700_MAG: format_item_name('AK_4700_MAG'),
    THERM_PAK: format_item_name('THERM_PAK'),
    CRYSPRISM: format_item_name('CRYSPRISM'),
}

# Set of valid armor items for validation
VALID_ARMOR = {
    MYSTERIOUS_ARMOR,  # 0x04
    ANCIENT_ARMOR,     # 0x06
    UNIFORM,           # 0x24
    FLIGHT_JACKET,     # 0x25
    STEEL_MESH,        # 0x26
    FLAK_JACKET,       # 0x27
    LASER_REFLEC,      # 0x28
    COMBAT_ARMOR,      # 0x29
    THICK_SKIN,        # 0x2A
    ROUGH_SKIN,        # 0x2B
    THICK_FUR,         # 0x2C
    CARBON_ARMOR,      # 0x2D
    CIVILIAN_CLOTHES,  # 0x2E
    SPECIAL,           # 0x2F
    KEVLAR_SUIT,       # 0x38
}

# Set of valid weapons for validation
VALID_WEAPONS = {
    HANDS,           # 0x08
    POWERFIST,       # 0x09
    SONIC_MACE,      # 0x0A
    GYRO_PIKE,       # 0x0B
    NEURON_FLAIL,    # 0x0C
    DAGGER,          # 0x0D
    CRYO_CUTLAS,     # 0x0E
    POWER_AXE,       # 0x0F
    ENERGY_BLADE,    # 0x10
    EDGE_SPINNER,    # 0x11
    AUTO_PISTOL,     # 0x12
    SHOTGUN,         # 0x13
    HYPERUZI,        # 0x14
    AK_4700,         # 0x15
    GAUSS_RIFLE,     # 0x16
    THERMOCASTER,    # 0x17
    HAND_LASER,      # 0x18
    LR_LASER,        # 0x19
    PLASMA_GUN,      # 0x1A
    NEUTRON_GUN,     # 0x1B
    CLAWS,           # 0x1C
    TEETH,           # 0x1D
    THRASHER,        # 0x1E
    ACID_BREATH,     # 0x1F
    NERF_CANNON,     # 0x37
}

# Set of ammo and power cells for validation
VALID_AMMO = {
    AUTO_CLIP,        # 0x30
    SHOTGUN_PACK,     # 0x31
    HYPERUZI_MAG,     # 0x32
    GAUSS_RIFLE_MAG,  # 0x33
    AK_4700_MAG,      # 0x34
    THERM_PAK,        # 0x35
    CRYSPRISM,        # 0x36
}

# Set of valid inventory items (everything that can go in general inventory)
VALID_INVENTORY = {
    EMPTY_SLOT,        # 0xFF (special case)
    BURBULATOR,        # 0x00
    EA_PASSCARD,       # 0x01
    TRINOCULARS,       # 0x02
    ARISIAN_LENS,      # 0x03
    ENERGY_BALL,       # 0x05
    BOOK,              # 0x07
    HOLOPHONES,        # 0x39
    VAX_GRAPHER,       # 0x3A
    ANTIQUE_YOYO,      # 0x3B
    CRYOSCOPE,         # 0x3C
    CYBERDISK,         # 0x3D
    SZART_NEEDLE,      # 0x3E
    KNARLYBAR,         # 0x3F
    TESSELATOR,        # 0x20
    NANOBOT,           # 0x21
    MARK_V_TENG,       # 0x22
    VADROXON,          # 0x23
}.union(VALID_AMMO)  # Can also store ammo in inventory