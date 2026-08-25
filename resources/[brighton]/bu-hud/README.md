# bu-hud — HUD

The Brighton Union HUD replaces the stock qb-hud (stopped server-side in a 30-second loop) and hides the native GTA health/armor bars.

## Layout

- **Right of the minimap** — round status rings: health (green, %), armor (blue ring around health when equipped), stamina (only while tired), hunger and thirst with icons and percentages.
- **Bottom-right** — cash/bank, street name, clock.
- **Right edge** — collapsible hint panel (phone, tablet, inventory, menu keys) with a hide button; the choice is remembered.
- **Under the minimap** — the "Made by catelizn" line, stretched to the minimap width.

The client sends state to the NUI every 1.5 seconds. The panel follows the Brighton Union palette (60/30/10, no pure white).
