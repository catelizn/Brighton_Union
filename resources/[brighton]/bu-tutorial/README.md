# bu-tutorial — Newcomer path

An 8-stage onboarding quest led by **Mike Ford**, who meets new players at Los Santos International Airport.

## How it works

- A new character is created with no apartment and no starting point: the player spawns at the airport and sees a short arrival cinematic ("Los Santos", flight BU-77).
- Mike Ford stands outside the terminal with a blip and a target prompt. Talking to him opens the quest UI.
- Each stage has a **server-side requirement** that must actually be met before the reward is paid:
  1. **Meet Mike** — introduction, +$250
  2. **Phone** — buy a `phone` at a 24/7, +$500
  3. **ID card** — get an `id_card` at the city hall, +$750
  4. **Driver's license** — pass the category B exam, +$1500
  5. **Bank** — open a bank account and receive a personal account number, +$2000
  6. **Job** — get hired by the NPC at any job site, +$1000
  7. **Vehicle rental** — rent any vehicle from Steve Carter at the airport, +$2000
  8. **You made it** — final reward, +$5000

## Validation

Requirements are checked on the server: inventory lookups, license item metadata, `bu_bank_accounts` row for the bank stage, the `bu_job_progress`/job name for the job stage and `bu_rental_log` for the rental stage. Rewards go to the bank account with a `tutorial-stage-N` transaction reason.

## Persistence

Progress is stored in `bu_quest_progress` (auto-created on first run) and cached in memory. The HUD shows "Новичок x/8" progress and refreshes every 15 seconds.

## Integration

- `qb-multicharacter` triggers `bu-tutorial:client:arrival` for new characters.
- `qb-apartments` has starting apartments disabled so newcomers always begin at the airport.
