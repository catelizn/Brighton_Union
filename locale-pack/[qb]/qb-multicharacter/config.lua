Config = {}
-- Нативный интерьер (апартаменты из базовой карты): там светло и есть мебель,
-- координаты пола сняты в игре — не менять без переснятия.
Config.Interior = vector3(-763.2816, 330.0418, 199.4865)              -- Interior to load where characters are previewed
Config.DefaultSpawn = vector3(-1039.51, -2741.01, 13.89)              -- Default spawn coords if you have start apartments disabled
Config.DefaultSpawnHeading = 340.28                                     -- Face the airport exit
Config.PedCoords = vector4(-763.2816, 330.0418, 199.4865, 177.7942)   -- Create preview ped at these coordinates
Config.HiddenCoords = vector4(-779.0154, 326.1801, 196.0860, 91.0454) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(-763.1219, 326.8112, 200.0, 357.0954)     -- Camera coordinates for character preview screen
Config.EnableDeleteButton = true                                      -- Define if the player can delete the character or not
Config.customNationality = false                                     -- Defines if Nationality input is custom of blocked to the list of Countries
Config.SkipSelection = false                                          -- Skip the spawn selection and spawns the player at the last location

Config.DefaultNumberOfCharacters = 3                                  -- Максимум 3 персонажа на аккаунт Rockstar/Steam
Config.PlayersNumberOfCharacters = {                                  -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', numberOfChars = 2 },
}
