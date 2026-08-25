# bu-auth

Account system in the GTA5RP spirit: before the character list the player
sees a login/registration form. One account per FiveM license.

- Passwords are never stored in plain text: `SHA2(login + password, 256)` is
  computed in MariaDB.
- Brute-force protection: after `Config.MaxAttempts` failures the license gets
  a `Config.LockoutSeconds` pause.
- On success the player state `buAuthed` is set, which qb-multicharacter waits
  for before showing the character selection.
