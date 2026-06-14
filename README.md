# BBBlu

**BBBlu** is a lightweight, real-time overlay UI addon for Final Fantasy XI (Windower 4) designed specifically for Blue Mages (`BLU`). It automatically tracks and displays learnable Blue Magic spells from your current target and zone, cross-referencing your character's current spellbook to highlight what you still need to learn.

---

## Features

- **Target Detection:** Fetches spell data for your currently targeted monster.
- **Location Display:** Tracks and displays all unlearned Blue Magic spells available in your current zone, and which monsters provide them.
- **Spell Tracking:** Reads your character's known spells and color-codes the overlay list based on learned/unlearned.
- **Job-Aware Visibility:** Stays invisible and out of the way unless your main or sub-job is Blue Mage (`BLU`).
- **Customizable UI:** Adjustable overlays featuring custom text borders, positions, fonts, backgrounds, and specific colors for both learned and unlearned spells.
- **Blue Mage Skill Display:** Shows the minimum Blue Magic Skill required to learn the spell next to the spell name.
- **Spell Learned Audio Alert:** When you learn a new spell, alerts you audibly so that you don't have to search through your chat box to find out.

---

## Installation

1. Download the release zip.
2. Extract into Windower > addons
3. In-game, open your chat and enter the following to load the addon: `//lua l bbblu`
4. *(Optional)* To automatically load BBBlu every time you start the game, add `lua load bbblu` to your Windower `init.txt` script.

## Configuration

The addon automatically generates a character-specific or profile global setup via Windower's built-in `config` library. You can modify these properties directly by editing the `settings.xml` file.

---

### Key Customization Options

| XML Tag | Description | Default Value |
| :--- | :--- | :--- |
| `<colors><learned>` | RGB color code for spells your character **already knows**. | `128, 128, 128` (Muted Gray) |
| `<colors><unlearned>` | RGB color code for spells your character **needs to learn**. | `255, 255, 255` (Bright White) |
| `<display><bg><alpha>` | Opacity transparency configuration of the box background. | `180` (Semi-transparent) |
| `<display><text><font>` | Change the font face of the UI element window. | `Montserrat` |
| `<display><text><size>` | Adjust the font sizing of the listed text. | `11` |
| `<display><pos>` | Sets explicit screen tracking coordinate offsets (`x`, `y`). | `0, 0` (Top-Left, draggable) |
| `<show_location>` | Toggles visibility of the location component. Persists thru loads/reloads. | `true` |
| `<show_radar>` | Toggles visibility of the radar component. Persists thru loads/reloads. | `true` |
| `<track_learnable>` | **Toggles visibility for available spells.** Shows spells you do not know AND have the required Blue Magic skill to learn. | `true` |
| `<track_unlearnable>` | **Toggles visibility for unavailable spells.** Shows spells you already know OR lack the required Blue Magic skill to learn. | `true` |

---

### Usage & Commands
- Target an Enemy: Change your active target to any targetable monster. If the monster has learnable blue mage spells associated with it in database.db, the overlay will display them.
- Toggle Windows: Use the command `//bbblu zone` or `//bbblu location` to toggle the location spell list overlay. Use //bbblu radar to toggle the radar overlay. Your preferences will be saved for future sessions.
- Draggable UI: Simply left-click and drag the text block anywhere on your screen to suit your overlay preferences.

---

### Disclaimer
Please note that database for this project may contain inaccuracies or missing entries. Compiling this database required pulling a massive amount of information from various wikis and guides. As a newer player who is still actively learning the Blue Mage job while developing this, I am still finding mistakes myself. If you spot any errors, please feel free to report it so that I may correct it.

---

Special thanks to Kenshi, the creator of InfoBar, and Kainsin, creator of BLUAlert. Their code served as inspiration and guidance for me to create this project!
