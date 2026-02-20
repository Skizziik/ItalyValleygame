# Italy Valley

A Stardew Valley-inspired pixel art farming and life simulation game set in the Italian countryside. Inherit a rundown farm in a small coastal village, grow crops, raise animals, befriend the locals, and restore the community -- all under the Mediterranean sun.

---

## Tech Stack

- **Engine:** Godot 4.6
- **Language:** GDScript
- **Target platforms:** Windows, Linux, macOS

---

## How to Run

1. Install [Godot 4.6+](https://godotengine.org/download) (standard or .NET edition).
2. Clone or download this repository.
3. Open Godot and select **Import** -> navigate to the `project.godot` file in this folder.
4. Press **F5** (or the Play button) to run the project.

---

## Controls

| Key       | Action                |
|-----------|-----------------------|
| W/A/S/D   | Move                  |
| E         | Interact              |
| I         | Open/close inventory  |
| J         | Open/close quest log  |
| M         | Open/close map        |
| Q         | Quick-drop item       |
| C         | Open/close crafting   |
| Esc       | Pause / back / menu   |
| LMB       | Use tool / select     |
| Scroll    | Cycle hotbar slot     |

---

## Project Structure

```
gamepixel/
  project.godot
  scenes/           # All .tscn scene files
    player/
    world/
    ui/
    npcs/
  scripts/          # All .gd script files
    autoloads/      # Singletons (GameManager, EventBus, TimeManager, etc.)
    player/
    world/
    ui/
    items/
    systems/
  assets/           # Art, audio, fonts
    sprites/
    tilesets/
    audio/
    fonts/
    ui/
  data/             # JSON/Resource data files (items, crops, recipes, dialogue)
  docs/             # Documentation
    ROADMAP.md
    ASSETS_LICENSES.md
```

---

## Documentation

- [Development Roadmap](docs/ROADMAP.md) -- milestone-based plan with phase descriptions and status tracking.
- [Asset Licenses](docs/ASSETS_LICENSES.md) -- registry of all external assets, their sources, and license information.

---

## License

TBD -- License to be determined before public release.
