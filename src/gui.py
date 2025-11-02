#!/usr/bin/env python3
"""
Sentinel Worlds I: Future Magic Save Game Editor - GUI Version
A Tkinter-based graphical interface for editing save game files.

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

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import os
from typing import Optional

# Handle imports for both pip-installed and direct execution
try:
    from src import main as main_module
    from src.main import (
        validate_save_file, load_save_game, save_game, create_backup,
        initialize_save_data, app_state
    )
    from src.sw_constants import *
    from src.inventory_constants import ITEM_NAMES, VALID_ARMOR, VALID_WEAPONS, VALID_INVENTORY
except ModuleNotFoundError:
    import main as main_module
    from main import (
        validate_save_file, load_save_game, save_game, create_backup,
        initialize_save_data, app_state
    )
    from sw_constants import *
    from inventory_constants import ITEM_NAMES, VALID_ARMOR, VALID_WEAPONS, VALID_INVENTORY


class SentinelWorldsEditor(tk.Tk):
    """Main application window for the Sentinel Worlds save game editor."""

    def __init__(self):
        super().__init__()

        self.title("Sentinel Worlds I: Future Magic - Save Game Editor v0.5b")
        self.geometry("900x600")

        # Track unsaved changes
        self.has_changes = False
        self.current_file = None

        # Create menu bar
        self.create_menu_bar()

        # Create main layout
        self.create_widgets()

        # Handle window close
        self.protocol("WM_DELETE_WINDOW", self.on_closing)

        # Status bar
        self.status_var = tk.StringVar(value="No file loaded")
        self.create_status_bar()

    def create_menu_bar(self):
        """Create the menu bar with File menu."""
        menubar = tk.Menu(self)
        self.config(menu=menubar)

        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Open Save File...", command=self.open_file, accelerator="Cmd+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Cmd+S", state=tk.DISABLED)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.on_closing, accelerator="Cmd+Q")

        # Store reference to menu items we need to enable/disable
        self.file_menu = file_menu

        # Bind keyboard shortcuts
        self.bind_all("<Command-o>", lambda e: self.open_file())
        self.bind_all("<Command-s>", lambda e: self.save_file())
        self.bind_all("<Command-q>", lambda e: self.on_closing())

    def create_widgets(self):
        """Create the main UI layout."""
        # Create paned window for left/right split
        paned = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        # Left panel - Tree view for navigation
        left_frame = ttk.Frame(paned, width=250)
        paned.add(left_frame, weight=0)

        ttk.Label(left_frame, text="Save Game Structure", font=('TkDefaultFont', 10, 'bold')).pack(pady=(0, 5))

        # Tree view
        self.tree = ttk.Treeview(left_frame, selectmode='browse')
        self.tree.pack(fill=tk.BOTH, expand=True)
        self.tree.bind('<<TreeviewSelect>>', self.on_tree_select)

        # Right panel - Editor area
        right_frame = ttk.Frame(paned)
        paned.add(right_frame, weight=1)

        # Title for right panel
        self.right_title = tk.StringVar(value="Select an item to edit")
        ttk.Label(right_frame, textvariable=self.right_title,
                 font=('TkDefaultFont', 12, 'bold')).pack(pady=(0, 10))

        # Scrollable content area
        self.content_frame = ttk.Frame(right_frame)
        self.content_frame.pack(fill=tk.BOTH, expand=True)

        # Initial message
        self.show_welcome_message()

    def create_status_bar(self):
        """Create status bar at bottom of window."""
        status_frame = ttk.Frame(self, relief=tk.SUNKEN)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)

        ttk.Label(status_frame, textvariable=self.status_var, anchor=tk.W).pack(side=tk.LEFT, padx=5)

        # Unsaved changes indicator
        self.changes_var = tk.StringVar(value="")
        self.changes_label = ttk.Label(status_frame, textvariable=self.changes_var,
                                       foreground="red", anchor=tk.E)
        self.changes_label.pack(side=tk.RIGHT, padx=5)

    def show_welcome_message(self):
        """Display welcome message when no file is loaded."""
        # Clear content frame
        for widget in self.content_frame.winfo_children():
            widget.destroy()

        welcome = ttk.Label(self.content_frame,
                           text="Welcome to Sentinel Worlds Save Game Editor\n\n"
                                "Choose File → Open Save File to begin",
                           justify=tk.CENTER,
                           font=('TkDefaultFont', 11))
        welcome.pack(expand=True)

    def open_file(self):
        """Open a save game file."""
        filename = filedialog.askopenfilename(
            title="Select Sentinel Worlds Save File",
            filetypes=[("Sentinel Worlds Save", "*.fm *.FM"), ("All files", "*.*")],
            initialdir=os.path.expanduser("~/Documents")
        )

        if not filename:
            return

        # Validate the file
        is_valid, message = validate_save_file(filename)
        if not is_valid:
            messagebox.showerror("Invalid Save File", message)
            return

        # Create backup
        create_backup(filename)

        # Load the save game
        try:
            main_module.save_game_data = load_save_game(filename)
            self.current_file = filename
            app_state['current_file'] = filename
            app_state['file_loaded'] = True

            # Update UI
            self.populate_tree()
            self.status_var.set(f"Loaded: {os.path.basename(filename)}")
            self.file_menu.entryconfig("Save", state=tk.NORMAL)
            self.has_changes = False
            self.update_changes_indicator()

        except Exception as e:
            messagebox.showerror("Error Loading File", f"Failed to load save file:\n{e}")

    def save_file(self):
        """Save changes to the current file."""
        if not self.current_file or not self.has_changes:
            return

        try:
            if save_game(self.current_file):
                self.has_changes = False
                self.update_changes_indicator()
                self.status_var.set(f"Saved: {os.path.basename(self.current_file)}")
                messagebox.showinfo("Success", "Changes saved successfully!")
        except Exception as e:
            messagebox.showerror("Error Saving", f"Failed to save file:\n{e}")

    def mark_changed(self):
        """Mark that the save file has been modified."""
        self.has_changes = True
        app_state['has_changes'] = True
        self.update_changes_indicator()

    def update_changes_indicator(self):
        """Update the unsaved changes indicator."""
        if self.has_changes:
            self.changes_var.set("● Unsaved changes")
        else:
            self.changes_var.set("")

    def populate_tree(self):
        """Populate the tree view with save game structure."""
        # Clear existing tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        # Party-wide items
        party = self.tree.insert('', 'end', text='Party', tags=('party',))
        self.tree.insert(party, 'end', text='Cash', values=('party_cash',))
        self.tree.insert(party, 'end', text='Light Energy', values=('party_light',))

        # Ship
        ship = self.tree.insert('', 'end', text='Ship Software', tags=('ship',))
        self.tree.insert(ship, 'end', text='All Software', values=('ship_software',))

        # Crew members
        crew_parent = self.tree.insert('', 'end', text='Crew Members', tags=('crew',))
        for i in range(1, 6):
            crew_name = main_module.save_game_data['crew'][i]['name']
            member = self.tree.insert(crew_parent, 'end',
                                     text=f"Crew {i}: {crew_name}",
                                     values=(f'crew_{i}',))
            self.tree.insert(member, 'end', text='Characteristics', values=(f'crew_{i}_char',))
            self.tree.insert(member, 'end', text='Abilities', values=(f'crew_{i}_abil',))
            self.tree.insert(member, 'end', text='Hit Points', values=(f'crew_{i}_hp',))
            self.tree.insert(member, 'end', text='Equipment', values=(f'crew_{i}_equip',))

        # Expand party and crew by default
        self.tree.item(party, open=True)
        self.tree.item(crew_parent, open=True)

    def on_tree_select(self, event):
        """Handle tree selection changes."""
        selection = self.tree.selection()
        if not selection:
            return

        item = selection[0]
        values = self.tree.item(item, 'values')

        if not values:
            return

        item_type = values[0]

        # Route to appropriate editor
        if item_type == 'party_cash':
            self.show_cash_editor()
        elif item_type == 'party_light':
            self.show_light_editor()
        elif item_type == 'ship_software':
            self.show_ship_editor()
        elif item_type.startswith('crew_'):
            parts = item_type.split('_')
            crew_num = int(parts[1])
            if len(parts) == 2:
                # Main crew item selected
                pass
            elif parts[2] == 'char':
                self.show_characteristics_editor(crew_num)
            elif parts[2] == 'abil':
                self.show_abilities_editor(crew_num)
            elif parts[2] == 'hp':
                self.show_hp_editor(crew_num)
            elif parts[2] == 'equip':
                self.show_equipment_editor(crew_num)

    def clear_content(self):
        """Clear the content frame."""
        for widget in self.content_frame.winfo_children():
            widget.destroy()

    def create_labeled_entry(self, parent, label_text, current_value, max_value=None):
        """Create a labeled entry field with current value."""
        frame = ttk.Frame(parent)
        frame.pack(fill=tk.X, pady=2)

        label = ttk.Label(frame, text=label_text, width=20)
        label.pack(side=tk.LEFT, padx=(0, 10))

        var = tk.StringVar(value=str(current_value))
        entry = ttk.Entry(frame, textvariable=var, width=15)
        entry.pack(side=tk.LEFT)

        if max_value:
            ttk.Label(frame, text=f"(max: {max_value})", foreground="gray").pack(side=tk.LEFT, padx=(5, 0))

        return var

    def show_cash_editor(self):
        """Show the party cash editor."""
        self.clear_content()
        self.right_title.set("Edit Party Cash")

        current_cash = main_module.save_game_data['party']['cash']

        ttk.Label(self.content_frame, text=f"Current cash: {current_cash:,}").pack(pady=10)

        var = self.create_labeled_entry(self.content_frame, "New value:", current_cash, MAX_CASH)

        def save_cash():
            try:
                new_value = int(var.get())
                if 0 <= new_value <= MAX_CASH:
                    main_module.save_game_data['party']['cash'] = new_value
                    self.mark_changed()
                    messagebox.showinfo("Success", f"Cash updated to {new_value:,}")
                    self.show_cash_editor()  # Refresh display
                else:
                    messagebox.showerror("Invalid Value", f"Cash must be between 0 and {MAX_CASH:,}")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter a valid number")

        ttk.Button(self.content_frame, text="Update Cash", command=save_cash).pack(pady=10)

    def show_light_editor(self):
        """Show the light energy editor."""
        self.clear_content()
        self.right_title.set("Edit Light Energy")

        current_light = main_module.save_game_data['party']['light_energy']

        ttk.Label(self.content_frame, text=f"Current light energy: {current_light}").pack(pady=10)

        var = self.create_labeled_entry(self.content_frame, "New value:", current_light, MAX_LIGHT_ENERGY)

        def save_light():
            try:
                new_value = int(var.get())
                if 0 <= new_value <= MAX_LIGHT_ENERGY:
                    main_module.save_game_data['party']['light_energy'] = new_value
                    self.mark_changed()
                    messagebox.showinfo("Success", f"Light energy updated to {new_value}")
                    self.show_light_editor()
                else:
                    messagebox.showerror("Invalid Value", f"Light energy must be between 0 and {MAX_LIGHT_ENERGY}")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter a valid number")

        ttk.Button(self.content_frame, text="Update Light Energy", command=save_light).pack(pady=10)

    def show_ship_editor(self):
        """Show the ship software editor."""
        self.clear_content()
        self.right_title.set("Edit Ship Software")

        ship = main_module.save_game_data['ship']

        ttk.Label(self.content_frame, text="Current values:", font=('TkDefaultFont', 10, 'bold')).pack(pady=10)

        vars_dict = {}
        for key in ['move', 'target', 'engine', 'laser']:
            vars_dict[key] = self.create_labeled_entry(
                self.content_frame,
                f"{key.upper()}:",
                ship[key],
                MAX_SHIP_SOFTWARE
            )

        def save_ship():
            try:
                changes_made = False
                for key, var in vars_dict.items():
                    new_value = int(var.get())
                    if not (0 <= new_value <= MAX_SHIP_SOFTWARE):
                        messagebox.showerror("Invalid Value",
                                           f"{key.upper()} must be between 0 and {MAX_SHIP_SOFTWARE}")
                        return
                    if main_module.save_game_data['ship'][key] != new_value:
                        main_module.save_game_data['ship'][key] = new_value
                        changes_made = True

                if changes_made:
                    self.mark_changed()
                    messagebox.showinfo("Success", "Ship software updated")
                    self.show_ship_editor()
                else:
                    messagebox.showinfo("No Changes", "No values were changed")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter valid numbers")

        ttk.Button(self.content_frame, text="Update Ship Software", command=save_ship).pack(pady=15)

    def show_characteristics_editor(self, crew_num: int):
        """Show the characteristics editor for a crew member."""
        self.clear_content()
        crew_name = main_module.save_game_data['crew'][crew_num]['name']
        self.right_title.set(f"Edit Characteristics - {crew_name}")

        chars = main_module.save_game_data['crew'][crew_num]['characteristics']

        ttk.Label(self.content_frame, text="Current values:", font=('TkDefaultFont', 10, 'bold')).pack(pady=10)

        vars_dict = {}
        for key in ['strength', 'stamina', 'dexterity', 'comprehend', 'charisma']:
            vars_dict[key] = self.create_labeled_entry(
                self.content_frame,
                f"{key.capitalize()}:",
                chars[key],
                MAX_STAT
            )

        def save_chars():
            try:
                changes_made = False
                for key, var in vars_dict.items():
                    new_value = int(var.get())
                    if not (0 <= new_value <= MAX_STAT):
                        messagebox.showerror("Invalid Value",
                                           f"{key.capitalize()} must be between 0 and {MAX_STAT}")
                        return
                    if chars[key] != new_value:
                        chars[key] = new_value
                        changes_made = True

                if changes_made:
                    self.mark_changed()
                    messagebox.showinfo("Success", f"Characteristics updated for {crew_name}")
                    self.show_characteristics_editor(crew_num)
                else:
                    messagebox.showinfo("No Changes", "No values were changed")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter valid numbers")

        ttk.Button(self.content_frame, text="Update Characteristics", command=save_chars).pack(pady=15)

    def show_abilities_editor(self, crew_num: int):
        """Show the abilities editor for a crew member."""
        self.clear_content()
        crew_name = main_module.save_game_data['crew'][crew_num]['name']
        self.right_title.set(f"Edit Abilities - {crew_name}")

        abilities = main_module.save_game_data['crew'][crew_num]['abilities']

        ttk.Label(self.content_frame, text="Current values:", font=('TkDefaultFont', 10, 'bold')).pack(pady=10)

        # Create scrollable frame for abilities
        canvas = tk.Canvas(self.content_frame)
        scrollbar = ttk.Scrollbar(self.content_frame, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        vars_dict = {}
        ability_names = ['contact', 'edged', 'projectile', 'blaster', 'tactics', 'recon',
                        'gunnery', 'atv_repair', 'mining', 'athletics', 'observation', 'bribery']

        for key in ability_names:
            display_name = key.replace('_', ' ').title()
            vars_dict[key] = self.create_labeled_entry(
                scrollable_frame,
                f"{display_name}:",
                abilities[key],
                MAX_STAT
            )

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        def save_abilities():
            try:
                changes_made = False
                for key, var in vars_dict.items():
                    new_value = int(var.get())
                    if not (0 <= new_value <= MAX_STAT):
                        messagebox.showerror("Invalid Value",
                                           f"{key.replace('_', ' ').title()} must be between 0 and {MAX_STAT}")
                        return
                    if abilities[key] != new_value:
                        abilities[key] = new_value
                        changes_made = True

                if changes_made:
                    self.mark_changed()
                    messagebox.showinfo("Success", f"Abilities updated for {crew_name}")
                    self.show_abilities_editor(crew_num)
                else:
                    messagebox.showinfo("No Changes", "No values were changed")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter valid numbers")

        ttk.Button(self.content_frame, text="Update Abilities", command=save_abilities).pack(pady=15)

    def show_hp_editor(self, crew_num: int):
        """Show the HP editor for a crew member."""
        self.clear_content()
        crew_name = main_module.save_game_data['crew'][crew_num]['name']
        self.right_title.set(f"Edit Hit Points - {crew_name}")

        current_hp = main_module.save_game_data['crew'][crew_num]['hp']

        ttk.Label(self.content_frame, text=f"Current HP: {current_hp}").pack(pady=10)

        var = self.create_labeled_entry(self.content_frame, "New HP:", current_hp, MAX_HP)

        def save_hp():
            try:
                new_value = int(var.get())
                if 0 <= new_value <= MAX_HP:
                    main_module.save_game_data['crew'][crew_num]['hp'] = new_value
                    self.mark_changed()
                    messagebox.showinfo("Success", f"HP updated to {new_value}")
                    self.show_hp_editor(crew_num)
                else:
                    messagebox.showerror("Invalid Value", f"HP must be between 0 and {MAX_HP}")
            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter a valid number")

        ttk.Button(self.content_frame, text="Update HP", command=save_hp).pack(pady=10)

    def show_equipment_editor(self, crew_num: int):
        """Show the equipment editor for a crew member."""
        self.clear_content()
        crew_name = main_module.save_game_data['crew'][crew_num]['name']
        self.right_title.set(f"Edit Equipment - {crew_name}")

        equipment = main_module.save_game_data['crew'][crew_num]['equipment']

        # Create scrollable canvas for equipment editing
        canvas = tk.Canvas(self.content_frame)
        scrollbar = ttk.Scrollbar(self.content_frame, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        # Storage for dropdown variables
        dropdowns = {}

        # Helper function to create item lists for dropdowns
        def get_armor_list():
            """Get list of armor items sorted by name."""
            items = [(ITEM_NAMES.get(code, f"Unknown {hex(code)}"), code) for code in sorted(VALID_ARMOR)]
            return items

        def get_weapon_list():
            """Get list of weapon items sorted by name."""
            items = [(ITEM_NAMES.get(code, f"Unknown {hex(code)}"), code) for code in sorted(VALID_WEAPONS)]
            return items

        def get_inventory_list():
            """Get list of all valid inventory items sorted by name."""
            items = [(ITEM_NAMES.get(code, f"Unknown {hex(code)}"), code) for code in sorted(VALID_INVENTORY)]
            return items

        # Equipped Armor
        ttk.Label(scrollable_frame, text="Equipped Armor:", font=('TkDefaultFont', 10, 'bold')).grid(
            row=0, column=0, sticky='w', padx=10, pady=(10, 5)
        )
        armor_items = get_armor_list()
        armor_names = [name for name, _ in armor_items]
        armor_codes = {name: code for name, code in armor_items}

        current_armor_name = ITEM_NAMES.get(equipment['armor'], f"Unknown {hex(equipment['armor'])}")
        dropdowns['armor'] = ttk.Combobox(scrollable_frame, values=armor_names, state='readonly', width=30)
        dropdowns['armor'].set(current_armor_name)
        dropdowns['armor'].grid(row=0, column=1, padx=10, pady=(10, 5))

        # Equipped Weapon
        ttk.Label(scrollable_frame, text="Equipped Weapon:", font=('TkDefaultFont', 10, 'bold')).grid(
            row=1, column=0, sticky='w', padx=10, pady=5
        )
        weapon_items = get_weapon_list()
        weapon_names = [name for name, _ in weapon_items]
        weapon_codes = {name: code for name, code in weapon_items}

        current_weapon_name = ITEM_NAMES.get(equipment['weapon'], f"Unknown {hex(equipment['weapon'])}")
        dropdowns['weapon'] = ttk.Combobox(scrollable_frame, values=weapon_names, state='readonly', width=30)
        dropdowns['weapon'].set(current_weapon_name)
        dropdowns['weapon'].grid(row=1, column=1, padx=10, pady=5)

        # On-hand Weapons
        ttk.Label(scrollable_frame, text="On-hand Weapons:", font=('TkDefaultFont', 10, 'bold')).grid(
            row=2, column=0, columnspan=2, sticky='w', padx=10, pady=(15, 5)
        )

        dropdowns['onhand'] = []
        for i in range(3):
            label_text = f"  Slot {i+1}:"
            ttk.Label(scrollable_frame, text=label_text).grid(
                row=3+i, column=0, sticky='w', padx=20, pady=2
            )

            current_item_name = ITEM_NAMES.get(equipment['onhand_weapons'][i],
                                               f"Unknown {hex(equipment['onhand_weapons'][i])}")
            combo = ttk.Combobox(scrollable_frame, values=weapon_names, state='readonly', width=30)
            combo.set(current_item_name)
            combo.grid(row=3+i, column=1, padx=10, pady=2)
            dropdowns['onhand'].append(combo)

        # Inventory
        ttk.Label(scrollable_frame, text="Inventory:", font=('TkDefaultFont', 10, 'bold')).grid(
            row=6, column=0, columnspan=2, sticky='w', padx=10, pady=(15, 5)
        )

        inventory_items = get_inventory_list()
        inventory_names = [name for name, _ in inventory_items]
        inventory_codes = {name: code for name, code in inventory_items}

        dropdowns['inventory'] = []
        for i in range(8):
            label_text = f"  Slot {i+1}:"
            ttk.Label(scrollable_frame, text=label_text).grid(
                row=7+i, column=0, sticky='w', padx=20, pady=2
            )

            current_item_name = ITEM_NAMES.get(equipment['inventory'][i],
                                               f"Unknown {hex(equipment['inventory'][i])}")
            combo = ttk.Combobox(scrollable_frame, values=inventory_names, state='readonly', width=30)
            combo.set(current_item_name)
            combo.grid(row=7+i, column=1, padx=10, pady=2)
            dropdowns['inventory'].append(combo)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Save function
        def save_equipment():
            try:
                changes_made = False

                # Update armor
                new_armor_name = dropdowns['armor'].get()
                new_armor_code = armor_codes.get(new_armor_name)
                if new_armor_code is not None and equipment['armor'] != new_armor_code:
                    equipment['armor'] = new_armor_code
                    changes_made = True

                # Update equipped weapon
                new_weapon_name = dropdowns['weapon'].get()
                new_weapon_code = weapon_codes.get(new_weapon_name)
                if new_weapon_code is not None and equipment['weapon'] != new_weapon_code:
                    equipment['weapon'] = new_weapon_code
                    changes_made = True

                # Update on-hand weapons
                for i, combo in enumerate(dropdowns['onhand']):
                    new_item_name = combo.get()
                    new_item_code = weapon_codes.get(new_item_name)
                    if new_item_code is not None and equipment['onhand_weapons'][i] != new_item_code:
                        equipment['onhand_weapons'][i] = new_item_code
                        changes_made = True

                # Update inventory
                for i, combo in enumerate(dropdowns['inventory']):
                    new_item_name = combo.get()
                    new_item_code = inventory_codes.get(new_item_name)
                    if new_item_code is not None and equipment['inventory'][i] != new_item_code:
                        equipment['inventory'][i] = new_item_code
                        changes_made = True

                if changes_made:
                    self.mark_changed()
                    messagebox.showinfo("Success", f"Equipment updated for {crew_name}")
                    self.show_equipment_editor(crew_num)  # Refresh display
                else:
                    messagebox.showinfo("No Changes", "No equipment was changed")

            except Exception as e:
                messagebox.showerror("Error", f"Failed to update equipment: {e}")

        ttk.Button(self.content_frame, text="Update Equipment", command=save_equipment).pack(pady=10)

    def on_closing(self):
        """Handle window close event."""
        if self.has_changes:
            response = messagebox.askyesnocancel(
                "Unsaved Changes",
                "You have unsaved changes. Save before exiting?"
            )
            if response is None:  # Cancel
                return
            elif response:  # Yes
                self.save_file()

        self.destroy()


def main():
    """Main entry point for the GUI version."""
    app = SentinelWorldsEditor()
    app.mainloop()


if __name__ == "__main__":
    main()
