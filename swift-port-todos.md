# Swift Port - Active Todos

## Project Context

This is a **native macOS SwiftUI port** of the Sentinel Worlds I save game editor, originally written in Python/Tkinter (2,353 lines). The Swift version is GUI-only with full feature parity.

### Port Implementation (7 Phases, Completed 2025-12-15)

1. **Phase 0: Project Setup** - Xcode project, GPL headers, git branch `swift-native`
2. **Phase 1: Binary I/O** - Little-endian byte operations (critical foundation, 19 unit tests)
3. **Phase 2: Data Model** - Constants, SaveGame/Party/Ship/CrewMember classes
4. **Phase 3: MVP GUI** - File loading, validation, read-only display
5. **Phase 4: Editing** - Input fields, validation, save functionality
6. **Phase 5: Navigation** - Tree sidebar with master-detail layout
7. **Phase 6: Equipment** - 65-item dropdowns for armor/weapons/inventory
8. **Phase 7: Polish** - Menu bar, keyboard shortcuts, unsaved changes warnings
9. **Phase 8: Advanced Features** - Global undo/redo, original value display

### Key Technical Decisions

**Binary I/O:**
- Little-endian byte order via `UInt32(littleEndian:)` pattern
- Thoroughly tested with 19 unit tests (saves are MS-DOS binary format)

**State Management:**
- `SaveGame` is the root ObservableObject
- Nested classes (Party/Ship/CrewMember) are regular classes (malloc crash workaround)
- Custom Binding wrappers for editor interactions
- `@State + @FocusState` pattern for input fields

**Undo/Redo:**
- Global UndoManager registered on `SaveGame` object (single undo target)
- All 159 editable fields support undo/redo across editors
- `.onReceive(saveGame.objectWillChange)` syncs @State when undo occurs

**Menu Integration:**
- SwiftUI FocusedValue system for menu command state
- WindowDelegate intercepts close events for unsaved changes warnings

**Equipment Arrays:**
- Individual properties (onhandWeapon1-3, inventory1-8) instead of arrays
- Workaround for malloc crash with ObservableObject arrays
- Functional impact: none (just verbose code)

### Current Build Status
- ✅ Clean build, zero errors
- ✅ 37 unit tests passing (19 BinaryFileIO + 18 Constants)
- ✅ GPL-3.0 license headers on all files
- ✅ All features functional
- ✅ Portrait infrastructure complete (data model, I/O, constants)

---

## Active Todos

### High Priority

- [x] **Portrait Infrastructure (Completed 2025-12-15)**
  - ✅ Added portrait hex addresses to SaveFileConstants (0x240, 0x300, 0x3C0, 0x480, 0x540)
  - ✅ Created PortraitConstants.swift with 8 portraits, nicknames, and helper functions
  - ✅ Added portrait property to CrewMember model and OriginalCrewMember
  - ✅ Updated SaveFileService to read/write portrait values from save files
  - ⚠️ **NEXT STEP:** Add PortraitConstants.swift to Xcode project (File > Add Files)

- [ ] **Crew Portrait Display & Editor** - Implement portrait UI
  - Display portrait image for selected crew member in editor area
  - Add portrait picker dropdown (8 options: Mike, Bluehair, Burke, Roger, Allison, TJ, Casey, Glasses)
  - Support undo/redo for portrait changes
  - Show original portrait value indicator
  - Portrait images: p01-p08 in Assets.xcassets "CrewPortraits" folder
  - Consider placement: HP editor section or dedicated portrait editor

### Medium Priority

- [ ] Manual testing with all user save files
- [x] User documentation for Swift version
- [x] Update main README.md to reference Swift native app (v0.7 for both versions)
- [ ] Code signing for distribution

### Low Priority

- [ ] Window size/position persistence (requires AppKit bridging)
- [ ] Recent files menu
- [ ] Drag-and-drop file opening
- [ ] Dark mode testing/optimization

### Future Enhancements

- [ ] Export save data to JSON/text format
- [ ] Backup file creation (.bak) with proper entitlements
- [ ] Keyboard navigation in tree (arrow keys)
- [ ] Accessibility labels (VoiceOver support)

---

## Notes

**Test Data:** Real save files in `test_data/` directory (gitignored)
**Inspector Tool:** `./venv/bin/python3 tests/test_inspector.py` displays all save values
**Python Version:** Still available at `src/main.py` (CLI) and `src/gui.py` (Tkinter GUI)

**Architecture:** ~26 Swift files, ~2,600 lines of code
- Models/ - SaveGame, Party, Ship, CrewMember data structures
- Constants/ - Hex addresses (SaveFileConstants), item definitions (ItemConstants), portrait mappings (PortraitConstants)
- Services/ - BinaryFileIO, SaveFileValidator, SaveFileService
- Views/ - ContentView, 8 editors, navigation components
