# bu-jobs — Jobs engine

A leveled job system (0–10) where pay per action scales with level, plus taxi and trucking order systems.

## Hiring

Jobs are **not** assigned at the city hall. Every job has a uniformed NPC at its work site; talking to the NPC hires you (server-side `SetJob`, distance check included).

| Job | NPC at | Model |
| --- | --- | --- |
| Почтальон | GO Postal depot | `s_m_m_postal_01` |
| Лесоруб | forest zone | `s_m_m_lathandy_01` |
| Грибник | mushroom zone | `a_m_m_farmer_01` |
| Шахтёр | mine | `s_m_m_miner_01` |
| Нефтяник | oil field | `s_m_m_dockwork_01` |
| Мясник | slaughterhouse | `s_m_m_linecook` |
| Рыбак | pier (license required) | `a_m_y_beach_01` |
| Охотник | hunting zone (license required) | `a_m_m_hillbilly_01` |
| Такси | taxi depot | `s_m_m_busdriver_01` |
| Дальнобойщик | GO Postal depot | `s_m_m_trucker_01` |

## Progression

`bu_job_progress` holds XP and level per player and job. Pay multipliers go from 1.0× at level 0 to 2.0× at level 10. A 3-second cooldown prevents spam; gathering and selling validate distance on the server.

## Central market

Six buyers at the Legion Square market pay cash for wood, mushrooms, ore, oil, meat and fish.

## Hunting without cruelty

Deer are spawned by the server in the hunting zone. When one is killed, the nearest licensed hunter is credited by the **wildlife service**: a message says the shot was recorded and the animal will be collected, and the payment is transferred to their bank account. No skinning, no meat item.

## Taxi orders

Players order a taxi from the phone app, choosing a destination. The fare is `distance × 45/km × 1.3` (30% over NPC rates). On-duty taxi drivers see orders in the tablet app, accept them and get paid in cash when they finish near the destination.

## Trucking orders

Business owners order supplies through their business marker (`bu-properties`), which creates an order with a random warehouse pickup (port or Paleto Bay). Truckers see it in the tablet app, pick up the cargo, deliver it to the business and get paid; the business's supplies increase. When no player orders exist, five NPC routes are always available.
