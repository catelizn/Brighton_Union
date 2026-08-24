# bu-hud — HUD

The Brighton Union HUD replaces the stock qb-hud (which is stopped server-side in a 30-second loop).

## Layout

- **Bottom-left** — health, armor, hunger, thirst and stress bars, plus the "Made by catelizn" attribution.
- **Bottom-right** — cash/bank, street name, clock.
- **Top-right** — server logo, online count, newcomer quest progress (refreshed every 15 s) and hotkey hints (↑ Phone, ↓ Tablet, I Inventory, F2 Menu).

The client sends state to the NUI every 1.5 seconds. The panel follows the Brighton Union palette (60/30/10, no pure white).
