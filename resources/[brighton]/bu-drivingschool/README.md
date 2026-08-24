# bu-drivingschool — Driving & flight school

Two schools: the ground school on the parking lot at the Vinewood sign (white training cars parked nearby) and the flight school at LSIA.

## Categories

| Category | Vehicle | Price | Theory |
| --- | --- | --- | --- |
| A (motorcycles) | Bati | $500 | yes |
| B (cars) | Sultan | $1500 | yes |
| C (trucks) | Boxville | $3000 | yes |
| LV (helicopters) | Maverick | $20000 | no |
| LS (planes) | Dodo | $20000 | no |

## Theory exam

Five questions with multiple choices, pass mark 4/5. Results are validated on the server and stored in `bu_driving_theory`. Ground categories require a passed theory exam; air categories skip it.

## Practical exam — private instance

- The exam fee is charged first. The server then moves the player into a **personal routing bucket** (`100000 + source`), spawns an `EXAMxxx` vehicle and warps the player into it. Other players never see the exam.
- The route is a checkpoint chain: ground routes snap to road height on the client, air routes use fixed altitudes.
- Leaving the vehicle or running out of time (600 s) cancels the exam.
- Finishing is validated server-side: correct vehicle entity, distance to the final checkpoint.
- On pass or cancel the server deletes the vehicle, resets the bucket to 0 and teleports the player back to the school.

## License item

Categories merge into a single `driver_license` item with `info.type = "A,B,C"` style metadata, so police scripts can read all categories at once.
