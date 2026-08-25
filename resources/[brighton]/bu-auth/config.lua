Config = Config or {}

-- Минимальные требования к учётной записи
Config.MinUsernameLength = 3
Config.MaxUsernameLength = 16
Config.MinPasswordLength = 6
Config.MaxPasswordLength = 32

-- Защита от перебора: сколько неудачных попыток и пауза после них (сек)
Config.MaxAttempts = 5
Config.LockoutSeconds = 30
