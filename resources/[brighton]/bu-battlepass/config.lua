Config = Config or {}

Config.Season = 1
Config.XpPerTier = 100
Config.MaxTier = 10

-- Награды по ярусам (cash или item)
Config.Tiers = {
    [1]  = { cash = 2000 },
    [2]  = { cash = 2500 },
    [3]  = { cash = 3000 },
    [4]  = { cash = 4000 },
    [5]  = { cash = 5000, item = { name = 'letter', amount = 10 } },
    [6]  = { cash = 6000 },
    [7]  = { cash = 7500 },
    [8]  = { cash = 9000 },
    [9]  = { cash = 12000 },
    [10] = { cash = 20000, item = { name = 'lockpick', amount = 5 } }
}
