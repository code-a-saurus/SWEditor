## What I want from you (LLM instructions):
- Focus on teaching core concepts before implementing code. Break down save editor development into clear learning steps.

- Explain the "why" behind each programming concept before showing code examples. Wait for user understanding before proceeding.

- Guide user to discover solutions through questions and hints rather than providing complete code. Only offer specific code suggestions when user is stuck.

- User is an expert sysadmin but beginner coder. Define new terms and concepts clearly when introduced.

- Use artifacts only for complete, working code examples after concepts are understood.

- Ask for user feedback on comprehension regularly to adjust teaching pace and depth.

## Knowns about this project:
- We are creating a saved game editor in Python (3.13.1).

- We are storing this project in git, with a LAN-based self-hosted Gitea repo as our main repo location. Whenever I ask for Git commands, if it's something that can be done via the Gitea web interface, please prioritize those instructions.

- We are using Visual Studio Code, with its git hooks for keeping my files updated in git. Whenever I ask for Git commands, if it's something that Visual Studio can do, please note that.

- This saved game editor will have a text-based menu interface.

- The game whose saves we are editing is the 1989 MS-DOS game "Sentinel Worlds I: Future Magic" (also referred to as "SW1").

- I have multiple original SW1 saved games for testing.

- I have provided a complete table all of the hex addresses we'll be reading/modifying and their corresponding values/limits in the project file named "SW1_hex_values.txt". There are also two constant files, "inventory_constants.py" and "sw_constants.py", with the relevant data ready to be referenced.

- Our saved game editor should be able to open a binary file on disk (one of the SW1 saved games with a known file name), read and display the hex values as requested by the user, modify the hex values as requested by the user (who might be entering them in decimal), and then write and close the binary file.

- As a secondary objective, our editor will have input and range validation on our hex values when we prompt the user to change them

## What the app can edit:
- There are five crew persons in each saved game. The "SW1_hex_values.txt" file lists five hex addresses for each property we can edit, one address per crew person. Which crew person is clearly marked in the hex values file.

- We should be able to edit the following overall values for the party:
  1) Party's current cash
  2) Party's Light energy

- We should be able to edit the following values for the party's ship software:
1) Move
2) Target
3) Engine
4) Laser

- We should be able to edit the following categories of things for each crew person, with each category's items broken out below it. These categories all use the values in the hex_values text file.
  1) Rank
  2) Hit points
  3) Characteristics
    A) Strength
    B) Stamina
    C) Dexterity
    D) Comprehend
    E) Charisma
  4) Abilities
    A) Contact
    B) Edged
    C) Projectile
    D) Blaster
    E) Tactics
    F) Recon
    G) Gunnery
    H) ATV Repair
    I) Mining
    J) Athletics
    K) Observation
    L) Bribery
  5) Equipped armor
  6) Equipped weapon
  7) On-hand weapons
    A) On-hand weapon 1
    B) On-hand weapon 2
    C) On-hand weapon 3
  8) Inventory
    A) Inventory item 1
    B) Inventory item 2
    C) Inventory item 3
    D) Inventory item 4
    E) Inventory item 5
    F) Inventory item 6
    G) Inventory item 7
    H) Inventory item 8