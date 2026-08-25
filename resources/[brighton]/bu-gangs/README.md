# bu-gangs

Preset criminal gangs in the GTA:SA / Majestic RP tradition: The Families,
Ballas, Vagos, Bloods, Marabunta. Ten ranks (0–9, recruit → boss), join only
through the gang NPC on the block (`[E]`), `/quitgang` leaves.

The ghetto is split into 60 capture squares (5 neighborhoods × 12), each gang
starts with its home neighborhood. Rules:

- only a square **adjacent** to your gang's squares can be captured;
- hold the square for 60 seconds, staying inside — a rival gang member in the
  square cancels the capture;
- squares and ownership are visible **only to gang members**;
- hourly Payday at :00 pays `Config.ZonePayout` per owned square into the gang
  treasury (`/gangmoney`, `/gwithdraw` — boss only);
- controlling 100% of the ghetto pays a bonus to every gang member.

Mafia-style business wars live in `bu-mafias`.

