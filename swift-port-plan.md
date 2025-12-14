# Swift/macOS Native Port - Implementation Plan

## Overview

Port the Sentinel Worlds save game editor from Python/Tkinter (2,353 lines) to native macOS Swift/SwiftUI. Incremental MVP approach focusing on native look & feel.

**Key Decisions:**
- ✅ SwiftUI framework (modern, declarative)
- ✅ GUI only (no CLI)
- ✅ Incremental MVP approach
- ✅ VSCode + Xcode hybrid workflow
- ✅ New branch: `swift-native`
- ✅ All files must include GPL-3.0-or-later license header

## Development Workflow

**VSCode for:** Code editing with Claude, git operations, file management
**Xcode for:** Building (Cmd+B), running (Cmd+R), debugging, testing (Cmd+U)

**Pattern:** Edit in VSCode → Save → Switch to Xcode → Build/Run → Return to VSCode

---

## Phase 0: Project Setup (1-2 hours)

### Objective
Create Swift project structure, establish git workflow, verify toolchain.

### Tasks

1. **Create Git Branch**
   ```bash
   git checkout -b swift-native
   git push -u origin swift-native
   ```

2. **Create Xcode Project**
   - Open Xcode → New Project → macOS → App
   - Product Name: `SentinelWorldsEditor`
   - Interface: SwiftUI, Language: Swift
   - Location: `/Users/lee/Documents/Sentinel_Worlds_editor/SentinelWorldsEditor/`

3. **Directory Structure**
   ```
   SentinelWorldsEditor/
   ├── SentinelWorldsEditor/
   │   ├── SentinelWorldsEditorApp.swift
   │   ├── ContentView.swift
   │   ├── Models/           # Phase 2: Data structures
   │   ├── Services/         # Phase 1: Binary I/O
   │   ├── Views/            # Phase 3+: UI components
   │   ├── Constants/        # Phase 2: Address tables
   │   └── Resources/        # GPL header template
   └── SentinelWorldsEditorTests/
   ```

4. **Create GPL License Header Template**
   - File: `SentinelWorldsEditor/Resources/GPL-Header.txt`
   - Include standard GPL-3.0-or-later header
   - Use in all new Swift files

5. **Update .gitignore**
   ```
   # Xcode
   SentinelWorldsEditor/build/
   SentinelWorldsEditor/*.xcodeproj/xcuserdata/
   SentinelWorldsEditor/DerivedData/
   *.swp
   .DS_Store
   ```

6. **Hello World Test**
   - Modify ContentView to show "Sentinel Worlds Editor - Swift Port"
   - Build and run in Xcode to verify toolchain

### Deliverables
- [ ] Xcode project builds and runs
- [ ] Directory structure created
- [ ] GPL header template ready
- [ ] Git branch with initial commit

### Teaching Focus
Swift project structure, Xcode workspace, macOS app bundle, SwiftUI app lifecycle

---

## Phase 1: Core Binary I/O ⚠️ CRITICAL FOUNDATION (4-6 hours)

### Objective
Port Python's binary read/write functions with **PERFECT** little-endian handling. Everything depends on this being correct.

### Critical Files to Create

**`Services/BinaryFileIO.swift`** - Core binary I/O operations

Key functions to implement:
1. `readBytes(from:address:numBytes:) -> Int` - Read 1-3 bytes, little-endian
2. `writeBytes(to:address:value:numBytes:)` - Write 1-3 bytes, little-endian
3. `readString(from:address:length:) -> String` - Fixed-length ASCII
4. `writeString(to:address:value:length:)` - Space-padded ASCII

**Little-Endian Handling (CRITICAL):**
```swift
// Bytes [0x3F, 0x42, 0x00] must read as 0x00423F = 16959, NOT 0x3F4200!
// Use UInt32(littleEndian:) pattern for correct conversion
```

**`SentinelWorldsEditorTests/BinaryFileIOTests.swift`** - Comprehensive unit tests

Required tests:
- Single byte read/write
- Two-byte little-endian read (verify 0x3F, 0x42 → 0x423F)
- Three-byte little-endian read
- Round-trip test (write then read, verify same value)
- String read with space trimming
- String write with padding
- **Integration test:** Read party cash from real save file (test_data/GAMEA.FM)

### Validation Checklist
- [ ] All unit tests pass
- [ ] Little-endian verified: [0x3F, 0x42] reads as 0x423F, not 0x3F42
- [ ] Real save file test reads plausible party cash (0-655,359)
- [ ] Round-trip test succeeds for 1, 2, and 3 bytes
- [ ] Error handling works for invalid inputs

### Deliverables
- [ ] BinaryFileIO.swift with all 4 functions
- [ ] BinaryFileIOTests.swift with 8+ unit tests
- [ ] All tests passing (Cmd+U in Xcode)
- [ ] Documentation comments on public functions

### Teaching Focus
Swift types (UInt8/16/32, Int), byte order, Data type, FileHandle, error handling, XCTest

---

## Phase 2: Data Model & Constants (3-4 hours)

### Objective
Port Python's data structures and hex address constants to Swift.

### Files to Create

**`Constants/SaveFileConstants.swift`** - Hex addresses and max values

Replace Python's `globals()` dynamic lookup with static nested structs:
```swift
struct SaveFileConstants {
    static let partyCashAddress = 0x024C
    static let maxCash = 655359

    struct Crew1 {
        static let nameAddress = 0x01C1
        struct Characteristics {
            static let strength = 0x0230
            // ...
        }
    }
    // Repeat for Crew2-5

    static func crewAddresses(for crewNumber: Int) -> CrewAddresses { ... }
}
```

**`Constants/ItemConstants.swift`** - Item codes and names

Port Python's ITEM_NAMES dict and validation sets:
```swift
struct ItemConstants {
    static let itemNames: [UInt8: String] = [
        0x00: "Burbulator",
        0xFF: "Empty Slot",
        // ... all 65 items
    ]

    static let validArmor: Set<UInt8> = [0x04, 0x06, ...]  // 15 items
    static let validWeapons: Set<UInt8> = [0x08, 0x09, ...]  // 25 items
    static let validInventory: Set<UInt8> = ...

    static func itemName(for code: UInt8) -> String { ... }
}
```

**`Models/SaveGame.swift`** - Core data structures

```swift
class SaveGame: ObservableObject {
    @Published var party: Party
    @Published var ship: Ship
    @Published var crew: [CrewMember]  // 5 members
    var hasUnsavedChanges: Bool
    var fileURL: URL?
}

class Party: ObservableObject {
    @Published var cash: Int = 0
    @Published var lightEnergy: Int = 0
}

class Ship: ObservableObject {
    @Published var move, target, engine, laser: Int
}

class CrewMember: ObservableObject, Identifiable {
    let id: Int  // 1-5
    @Published var name: String
    @Published var hp, rank: Int
    @Published var characteristics: Characteristics
    @Published var abilities: Abilities
    @Published var equipment: Equipment
}
```

### Why ObservableObject & @Published?
Enables SwiftUI's automatic UI updates:
```swift
// In SwiftUI view:
TextField("HP", value: $crewMember.hp, formatter: NumberFormatter())
// Changes to crewMember.hp automatically update UI, and vice versa
```

### Deliverables
- [ ] All constants match Python values exactly
- [ ] Data structures compile without errors
- [ ] Basic unit test creates SaveGame instance
- [ ] Constants verified against sw_constants.py and inventory_constants.py

### Teaching Focus
Structs vs classes, ObservableObject, @Published, protocols, Sets/Dictionaries, type-safe constants

---

## Phase 3: MVP GUI - Read-Only Viewer (4-6 hours)

### Objective
Build minimal UI that loads and displays save file data (no editing yet).

### Files to Create

**`Services/SaveFileValidator.swift`** - File validation

Port Python's `validate_save_file()`:
```swift
struct SaveFileValidator {
    enum ValidationError: LocalizedError {
        case fileNotFound
        case fileTooLarge(size: Int)
        case invalidSignature
        // ...
    }

    static func validate(url: URL) throws {
        // Check exists, readable, size (1KB-16KB)
        // Check filename pattern: game[a-z].fm
        // Check "Sentinel" signature at 0x3181
        // Check directory writable
    }
}
```

**`Services/SaveFileService.swift`** - Load/save operations

```swift
class SaveFileService {
    static func load(from url: URL) throws -> SaveGame {
        // Open file
        // Use BinaryFileIO to read all values
        // Populate SaveGame model
        // Return loaded data
    }

    static func save(_ saveGame: SaveGame, to url: URL) throws {
        // Create .bak backup first
        // Use BinaryFileIO to write all values
        // Clear hasUnsavedChanges flag
    }
}
```

**`Views/MainView.swift`** - Main application window

```swift
struct MainView: View {
    @StateObject private var saveGame = SaveGame()
    @State private var statusMessage = "No file loaded"

    var body: some View {
        VStack {
            if saveGame.fileURL == nil {
                welcomeView  // "Choose File → Open to begin"
            } else {
                dataDisplayView  // Show all data in GroupBoxes
            }
            StatusBar(message: statusMessage, hasChanges: saveGame.hasUnsavedChanges)
        }
        .toolbar {
            Button("Open File...") { showingFilePicker = true }
        }
        .fileImporter(...) { handleFileSelection($0) }
    }
}
```

**`Views/Components/StatusBar.swift`** - Bottom status bar

Shows filename and "● Unsaved changes" indicator.

### Testing Checklist
- [ ] Load GAMEA.FM successfully
- [ ] Party cash displays correct value
- [ ] All 5 crew names display
- [ ] Validation rejects non-.fm files
- [ ] Validation rejects files without signature
- [ ] Status bar shows filename

### Deliverables
- [ ] App loads and displays save file data (read-only)
- [ ] File picker works (Cmd+O)
- [ ] Validation catches invalid files
- [ ] Data matches Python GUI values

### Teaching Focus
SwiftUI views, @State/@StateObject, file picker, alerts, VStack/HStack/GroupBox, toolbars

---

## Phase 4: Editing Capability (3-4 hours)

### Objective
Make UI editable, implement save functionality, track changes.

### Key Changes

**Replace read-only Text with editable TextField:**
```swift
// Before:
Text("\(crew.hp)")

// After:
TextField("", value: $crew.hp, formatter: NumberFormatter())
    .textFieldStyle(.roundedBorder)
    .frame(width: 80)
    .onChange(of: crew.hp) { _ in
        saveGame.hasUnsavedChanges = true
    }
```

**Add Save button to toolbar:**
```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Save") { handleSave() }
            .disabled(saveGame.fileURL == nil || !saveGame.hasUnsavedChanges)
            .keyboardShortcut("s", modifiers: .command)
    }
}
```

**Create ValidatedNumberField component:**
```swift
struct ValidatedNumberField: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let onChange: () -> Void

    var body: some View {
        HStack {
            Text(label + ":")
            TextField("", value: $value, formatter: NumberFormatter())
                .border(isInvalid ? Color.red : Color.clear, width: 2)
            if isInvalid {
                Text("(\(range.lowerBound)-\(range.upperBound))")
                    .foregroundColor(.red)
            }
        }
    }
}
```

**Complete SaveFileService.save():**
- Create backup (.bak file)
- Write all party/ship/crew data using BinaryFileIO
- Clear hasUnsavedChanges flag

### Testing Checklist
- [ ] Edit party cash, save, reload - value persists
- [ ] Edit crew HP, save, reload - value persists
- [ ] Backup file (.bak) created before save
- [ ] Invalid values show red border
- [ ] Unsaved changes indicator works
- [ ] Cmd+S saves file

### Deliverables
- [ ] All data fields editable
- [ ] Save button creates backup and writes changes
- [ ] Input validation prevents invalid values
- [ ] Change tracking works

### Teaching Focus
Two-way binding ($), TextField with formatters, onChange, button states, keyboard shortcuts

---

## Phase 5: Navigation Tree (4-6 hours)

### Objective
Add left-side tree navigation like Python GUI (master-detail pattern).

### Files to Create

**`Views/Sidebar/TreeNode.swift`** - Tree data model

```swift
struct TreeNode: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: NodeType
    let children: [TreeNode]?

    enum NodeType: Hashable {
        case party, partyCash, partyLight
        case ship, shipSoftware
        case crewRoot
        case crewMember(number: Int)
        case crewCharacteristics(crewNumber: Int)
        case crewAbilities(crewNumber: Int)
        case crewHP(crewNumber: Int)
        case crewEquipment(crewNumber: Int)
    }

    static func buildTree(from saveGame: SaveGame) -> [TreeNode] {
        // Build hierarchical structure
    }
}
```

**Refactor MainView.swift** - Use NavigationSplitView

```swift
struct MainView: View {
    @StateObject private var saveGame = SaveGame()
    @State private var selectedNode: TreeNode.NodeType?
    @State private var treeNodes: [TreeNode] = []

    var body: some View {
        NavigationSplitView {
            // Left sidebar - Tree navigation
            List(selection: $selectedNode) {
                ForEach(treeNodes) { node in
                    treeNodeView(node: node)
                }
            }
            .frame(minWidth: 200, idealWidth: 250)
        } detail: {
            // Right detail - Editor area
            EditorContainer(saveGame: saveGame, selectedNode: selectedNode)
        }
    }
}
```

**`Views/Editors/EditorContainer.swift`** - Routes to appropriate editor

```swift
struct EditorContainer: View {
    @ObservedObject var saveGame: SaveGame
    let selectedNode: TreeNode.NodeType?

    var body: some View {
        switch selectedNode {
        case .partyCash:
            PartyCashEditor(party: saveGame.party, onChanged: { ... })
        case .crewCharacteristics(let crewNum):
            CharacteristicsEditor(crew: saveGame.crew[crewNum - 1], ...)
        // ... etc
        default:
            placeholderView
        }
    }
}
```

**Create simple editor views:**
- PartyCashEditor.swift
- PartyLightEditor.swift
- ShipSoftwareEditor.swift
- CharacteristicsEditor.swift
- AbilitiesEditor.swift
- HPEditor.swift

### Tree Structure
```
Party
  Cash
  Light Energy
Ship Software
  All Software
Crew Members
  Crew 1: [Name]
    Characteristics
    Abilities
    Hit Points
    Equipment
  Crew 2-5: (same structure)
```

### Deliverables
- [ ] Collapsible tree navigation on left
- [ ] Clicking items shows editor on right
- [ ] Master-detail layout works
- [ ] Structure matches Python GUI

### Teaching Focus
NavigationSplitView, List with selection, DisclosureGroup, ViewBuilder, SF Symbols

---

## Phase 6: Equipment Editor with Dropdowns (4-6 hours)

### Objective
Build complex equipment editor with dropdown menus for 65 items.

### Files to Create

**`Views/Editors/EquipmentEditor.swift`**

```swift
struct EquipmentEditor: View {
    @ObservedObject var crew: CrewMember
    let onChanged: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Equipped Armor (1 dropdown)
                ItemPicker(
                    label: "Armor",
                    selectedItemCode: $crew.equipment.armor,
                    validItems: Array(ItemConstants.validArmor).sorted(),
                    onChange: onChanged
                )

                // Equipped Weapon (1 dropdown)
                ItemPicker(...)

                // On-hand Weapons (3 dropdowns)
                ForEach(0..<3) { index in
                    ItemPicker(
                        label: "Slot \(index + 1)",
                        selectedItemCode: Binding(
                            get: { crew.equipment.onhandWeapons[index] },
                            set: { crew.equipment.onhandWeapons[index] = $0 }
                        ),
                        validItems: Array(ItemConstants.validWeapons).sorted(),
                        onChange: onChanged
                    )
                }

                // Inventory (8 dropdowns)
                ForEach(0..<8) { ... }
            }
        }
    }
}
```

**`Views/Components/ItemPicker.swift`** - Reusable dropdown

```swift
struct ItemPicker: View {
    let label: String
    @Binding var selectedItemCode: UInt8
    let validItems: [UInt8]
    let onChange: () -> Void

    var body: some View {
        HStack {
            Text(label + ":")
            Picker("", selection: $selectedItemCode) {
                ForEach(validItems, id: \.self) { itemCode in
                    Text(ItemConstants.itemName(for: itemCode))
                        .tag(itemCode)
                }
            }
            .pickerStyle(.menu)  // Dropdown style
            .onChange(of: selectedItemCode) { _ in onChange() }
        }
    }
}
```

**Optional Enhancement:** Searchable picker for better UX with 65 items.

### Testing Checklist
- [ ] Armor dropdown shows only 15 valid items
- [ ] Weapon dropdown shows 25 valid weapons
- [ ] Inventory dropdown shows valid items + ammo
- [ ] Selecting item updates data model
- [ ] Save and reload preserves choices
- [ ] Empty Slot (0xFF) appears in lists

### Deliverables
- [ ] Equipment editor with 11 dropdown menus
- [ ] Dropdowns show human-readable names
- [ ] Only valid items in each dropdown
- [ ] Changes trigger unsaved indicator

### Teaching Focus
Picker views, custom Binding get/set, ForEach with indices, popover

---

## Phase 7: Polish & macOS Integration (3-5 hours)

### Objective
Add native macOS behaviors and final polish.

### Tasks

1. **Window Behaviors**
   - Window title shows filename and edited state
   - Unsaved changes warning on close/quit
   - Remember window size/position

2. **Keyboard Shortcuts**
   - Cmd+O: Open file
   - Cmd+S: Save file
   - Cmd+W: Close window (with warning)
   - Cmd+Q: Quit (with warning)

3. **Menu Bar**
   ```swift
   // In SentinelWorldsEditorApp.swift
   var body: some Scene {
       WindowGroup { MainView() }
       .commands {
           CommandGroup(replacing: .newItem) {}
           CommandMenu("File") {
               Button("Open...") { ... }
               Button("Save") { ... }
           }
           CommandGroup(after: .help) {
               Button("About") { ... }
               Button("View GPL License") { ... }
           }
       }
   }
   ```

4. **App Icon**
   - Create app icon in Assets.xcassets
   - Consider SF Symbol or custom retro design

5. **Error Handling**
   - User-friendly error dialogs
   - Logging for debugging

### Deliverables
- [ ] Window title shows filename and edited state
- [ ] Unsaved changes warning on quit
- [ ] Full keyboard shortcuts
- [ ] Custom menu bar
- [ ] App icon
- [ ] GPL license accessible from Help

### Teaching Focus
macOS window management, NSApplication, command menus, asset catalogs, app lifecycle

---

## Critical Implementation Notes

### 1. Little-Endian Byte Order ⚠️

**MUST TEST FIRST:**
```swift
// Verify: [0x3F, 0x42, 0x00] reads as 0x00423F = 16959, NOT 0x3F4200
let value = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 3)
XCTAssertEqual(value, 0x00423F)
XCTAssertEqual(value, 16959)
```

### 2. File Permissions & Sandboxing

macOS apps are sandboxed:
- Use NSOpenPanel (file picker) for temporary access
- For persistent access, use security-scoped bookmarks
- May need entitlement: `com.apple.security.files.user-selected.read-write`

### 3. Testing Strategy

**Unit Tests (XCTest):**
- Binary I/O functions (Phase 1) ← CRITICAL
- Data model initialization
- Validation logic

**Integration Tests:**
- Load real save file from test_data/
- Verify values match Python inspector output
- Round-trip test: load → modify → save → load → verify

**Manual GUI Tests:**
- Load each test save file
- Edit each type of field
- Verify backup creation
- Binary diff of saved file

### 4. Git Workflow

```bash
# After each phase:
git add SentinelWorldsEditor/
git commit -m "Phase N: [description]

- Feature 1
- Feature 2

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

git push origin swift-native
```

### 5. Common Swift Gotchas for Python Developers

| Python | Swift | Notes |
|--------|-------|-------|
| `dict['key']` | `dict["key"]?` | Optional in Swift |
| `range(1, 6)` | `1..<6` or `1...5` | Exclusive vs inclusive |
| `f"{value}"` | `"\(value)"` | String interpolation |
| `globals()["var"]` | ❌ No equivalent | Use static structs |
| `try/except` | `do/catch` | Similar concept |
| `with open():` | `defer { try? f.close() }` | Different pattern |

---

## Success Criteria

**Phase 1 Complete:** Binary I/O unit tests pass, little-endian verified
**Phase 2 Complete:** Data model compiles, constants match Python
**Phase 3 Complete:** Can load and display save file data
**Phase 4 Complete:** Can edit and save changes, backup created
**Phase 5 Complete:** Tree navigation works, master-detail pattern
**Phase 6 Complete:** Equipment dropdowns functional
**Phase 7 Complete:** Native macOS app with polish

**Final Success:** Load GAMEA.FM → Edit all fields → Save → Verify in Python GUI → Binary diff shows only expected changes

---

## Estimated Timeline

| Phase | Time | Complexity |
|-------|------|------------|
| 0: Setup | 1-2h | Simple |
| 1: Binary I/O ⚠️ | 4-6h | Medium (critical) |
| 2: Data Model | 3-4h | Medium |
| 3: MVP GUI | 4-6h | Medium |
| 4: Editing | 3-4h | Medium |
| 5: Navigation | 4-6h | Medium-Complex |
| 6: Equipment | 4-6h | Complex |
| 7: Polish | 3-5h | Medium |
| **Total** | **26-39h** | **1-2 weeks** |

---

## Next Steps

1. ✅ Review and approve this plan
2. Start Phase 0: Project setup
3. Focus Phase 1: Get binary I/O perfect
4. Test against real save files
5. Build incrementally, test each phase

Each phase should produce a working, testable result before proceeding to the next.
