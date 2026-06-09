# BBBlu

**BBBlu** is a lightweight, real-time overlay UI addon for Final Fantasy XI (Windower 4) designed specifically for Blue Mages (`BLU`). It automatically tracks and displays learnable Blue Magic spells from your current target, cross-referencing your character's current spellbook to highlight what you still need to learn.

---

## Features

- **Target Detection:** Fetches spell data for your currently targeted monster.
- **Spell Tracking:** Reads your character's known spells and color-codes the overlay list based on learned/unlearned.
- **Job-Aware Visibility:** Stays invisible and out of the way unless your main or sub-job is Blue Mage (`BLU`) and have a monster targeted.
- **Customizable UI:** Adjustable overlay featuring custom text borders, positions, fonts, backgrounds, and specific colors for both learned and unlearned spells.
- **Blue Mage Skill Display:** Shows the minimum Blue Magic Skill required to learn the spell next to the spell name.

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
| `<radar><track_learnable>` | **Toggles visibility for available spells.** Shows spells you do not know AND have the required Blue Magic skill to learn. | `true` |
| `<radar><track_unlearnable>` | **Toggles visibility for unavailable spells.** Shows spells you already know OR lack the required Blue Magic skill to learn. | `true` |

---

### Usage & Commands
- The addon works entirely passively in the background without needing manual text prompts.
- Target an Enemy: Change your active target to any targetable monster. If the monster has learnable blue mage spells associated with it in database.db, the overlay will display them.
- Draggable UI: Simply left-click and drag the text block anywhere on your screen to suit your overlay preferences.

---

Special thanks to Kenshi, the creator of InfoBar, and Kainsin, creator of BLUAlert. Their code served as inspiration and guidance for me to create this project!
