# bu-chat

Chat theme for the Brighton Union server. The default FiveM system chat is styled
through the `chat_theme` manifest entry: messages keep only the text and a soft
shadow, the background is almost transparent.

## How it works

- `fxmanifest.lua` registers the theme named `brighton` (`chat_theme` metadata).
- `style.css` is loaded inside the chat NUI frame and overrides the stock look.
- No scripts are attached: hiding the chat while the player is out of the world is
  handled by `bu-hud` through the built-in `toggleChat` command.

## Notes

- The theme applies to the built-in system chat, so the resource only has to be
  started once (`ensure bu-chat`).
- Requires a client build with `chat_theme` support (current FiveM b3258 does).
