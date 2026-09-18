Config = Config or {}

Config.BetMin = 100
Config.BetMax = 50000
Config.BetWindow = 20    -- секунд на ставки
Config.RaceLength = 12   -- секунд «гонка»
Config.Horses = {
    { name = 'Пегас',  color = 2 },
    { name = 'Молния', color = 1 },
    { name = 'Тень',   color = 3 },
    { name = 'Стрела', color = 5 }
}
-- Веса победы (больше = вероятнее)
Config.Weights = { 30, 20, 25, 25 }

Config.Spot = {
    coords = vector3(928.0, 47.0, 81.0),
    label = 'Тотализатор'
}
