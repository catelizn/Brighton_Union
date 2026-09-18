# bu-nametags

Brighton Union name tags above players' heads.

## How it works

- Every player sees a tag above other players **at any distance up to `Config.DrawDistance`** (default 30 m, server pushes data within `Config.GiveDistance` — 120 m).
- The tag always shows the **dynamic server ID**: `John Carter (3)`.
- **Real names** are shown only to players who:
  - shook hands in game (`/handshake` near another player), or
  - work in the same faction (same non-civilian job), or
  - are members of the same family.
- Everyone else sees `Гражданин (id)` for male characters and `Гражданка (id)` for female characters.

## Commands

| Command | Description |
| --- | --- |
| `/handshake` | Introduce yourself to the nearest player (within 2.5 m) |

## Database

Creates `bu_acquaintances` (citizenid_a, citizenid_b) automatically on start.

## Config

```lua
Config.DrawDistance = 30.0    -- draw distance for the tag
Config.GiveDistance = 120.0   -- server data radius
Config.SyncInterval = 2000    -- list refresh interval (ms)
Config.HandshakeDistance = 2.5
```
