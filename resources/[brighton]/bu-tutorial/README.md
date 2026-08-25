# bu-tutorial — Newcomer path

A 7-stage onboarding quest led by **Mike Ford**, who waves at new players on the upper level of Los Santos International Airport.

## How it works

- The character is created in a dressing room; the arrival at the airport (flight BU-77 cinematic, camera zoom on Mike) plays only after the character is confirmed.
- Mike Ford stands at the terminal doors with a blip and a target prompt. Talking to him opens the quest UI.
- Each stage has a **server-side requirement** that must actually be met before the reward is paid:
  1. **Meet Mike** — introduction, +$250
  2. **Phone** — buy a `phone` at a 24/7, +$500
  3. **Vehicle rental** — rent any vehicle from Steve Carter at the airport, +$1500
  4. **Bank** — open a bank account and receive a personal account number, +$2000
  5. **Driving school** — pass the category B exam, +$2500
  6. **First job** — get hired and earn $1000, +$1500
  7. **You made it** — final reward, +$3000

## Validation

Requirements are checked on the server: inventory lookups, `bu_bank_accounts` row for the bank stage, the `bu_job_progress`/job name for the job stage and `bu_rental_log` for the rental stage. Rewards go to the bank account with a `tutorial-stage-N` transaction reason.

## Persistence

Progress is stored in `bu_quest_progress` (auto-created on first run) and cached in memory. The HUD shows "Путь новичка x/7" progress and refreshes every 15 seconds.

## Integration

- Character creation runs in a dressing room; the arrival event fires when the character is confirmed (qb-clothing menu close).
- `qb-apartments` has starting apartments disabled so newcomers always begin at the airport.
