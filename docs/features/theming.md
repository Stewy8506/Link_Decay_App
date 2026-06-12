# Theming and Design Systems

LinkShelf is designed with a minimal, typographic, and tactile interface. It avoids neon, high-contrast, or overly saturated primary colors in favor of desaturated, organic tones inspired by architecture and physical materials.

This document details the visual style guide, neutral themes, typography support, and custom layout variables.

---

## ✦ Built-in Neutral Theme Palettes

LinkShelf provides four core neutral themes. Each theme defines a dark/light base configuration and a matching card visual accent:

| Theme Name | Primary Background | Highlight Accent | Aesthetic Style |
|---|---|---|---|
| **Warm Stone** (Default) | `#0E0D0C` | `#D9C3B0` | Earthy, warm organic sandstone tints. |
| **Cold Slate** | `#0B0C0E` | `#A0B0C0` | Cool, industrial architectural gray. |
| **Forest Moss** | `#0B0E0C` | `#A8C3A0` | Desaturated botanical sage green. |
| **Pitch Charcoal** | `#080808` | `#E0E0E0` | High-contrast deep monochrome carbon. |

---

## ✦ Custom Theme Adjustments

In addition to the presets, users can customize their experience through:
- **Custom Accent Color Input**: Custom HEX input cards (e.g. `#FF7733`) allow users to style active buttons, freshness indicator bars, and sidebar highlights.
- **Custom Background Color Input**: HEX colors let users customize active screen backdrops to match their device or desktop aesthetics.

---

## ✦ Typography Selection

Typography dynamically styles every component and text block in the app. Users can select from four distinct typefaces:

```
┌──────────────────────────────────────────────────────────┐
│                   Typography Profiles                    │
├──────────────────────────────────────────────────────────┤
│ 🔹 Inter           | Clean, highly readable sans-serif.  │
│ 🔸 Outfit          | Geometric, modern startup aesthetic.│
│ 🔹 Playfair Display| Elegant, classic editorial serif.   │
│ 🔸 JetBrains Mono  | Structured monospace coding font.   │
└──────────────────────────────────────────────────────────┘
```

---

## ✦ Design System Constraints

To maintain a consistent, polished layout across all screens and widgets, developers must follow these guidelines:
- **Spacing Grid**: Standard margins are set to `16.0` pixels.
- **Borders**: Interactive container elements use a `0.5px` thin border, aligning with standard premium minimalist design guidelines.
- **Animations**: Visual movements—such as the sliding selection bar or pull-down stats panel—use smooth animations with custom spring and deceleration curves (`decelerate` or custom `cubic-bezier`).
