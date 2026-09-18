local QBCore = exports['qb-core']:GetCoreObject()

-- Защита от перебора: license -> { fails, lockedUntil }
local attempts = {}

local function lockLeft(license)
    local entry = attempts[license]
    if not entry then return 0 end
    local left = entry.lockedUntil - os.time()
    return left > 0 and left or 0
end

local function registerFail(license)
    local entry = attempts[license]
    if not entry then
        entry = { fails = 0, lockedUntil = 0 }
        attempts[license] = entry
    end
    entry.fails = entry.fails + 1
    if entry.fails >= Config.MaxAttempts then
        entry.lockedUntil = os.time() + Config.LockoutSeconds
        entry.fails = 0
    end
end

local function validUsername(name)
    return name and name:match('^[a-zA-Z0-9_]+$') ~= nil
end

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_accounts` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `license` varchar(64) NOT NULL,
            `username` varchar(32) NOT NULL,
            `password` varchar(128) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_license` (`license`),
            UNIQUE KEY `uq_username` (`username`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

-- Вход или регистрация. Пароль хэшируется прямо в SQL: SHA2(логин + пароль).
-- Работает до выбора персонажа: QBCore-объекта игрока здесь ещё нет,
-- поэтому используется только лицензия и FiveM-стейт игрока.
QBCore.Functions.CreateCallback('bu-auth:server:auth', function(source, cb, mode, username, password)
    local src = source

    local license = QBCore.Functions.GetIdentifier(src, 'license')
    if not license then return cb({ ok = false, message = 'Не удалось определить лицензию.' }) end

    local left = lockLeft(license)
    if left > 0 then
        return cb({ ok = false, message = string.format('Слишком много попыток. Подожди %d секунд.', left) })
    end

    username = username and username:gsub('%s+', ''):lower()
    password = password or ''

    if not validUsername(username) or #username < Config.MinUsernameLength or #username > Config.MaxUsernameLength then
        return cb({ ok = false, message = string.format('Логин: %d–%d символов, только латиница и цифры.', Config.MinUsernameLength, Config.MaxUsernameLength) })
    end

    if #password < Config.MinPasswordLength or #password > Config.MaxPasswordLength then
        return cb({ ok = false, message = string.format('Пароль: %d–%d символов.', Config.MinPasswordLength, Config.MaxPasswordLength) })
    end

    if mode == 'register' then
        local exists = MySQL.query.await('SELECT id FROM bu_accounts WHERE license = ? LIMIT 1', { license })
        if exists and exists[1] then
            return cb({ ok = false, message = 'У этой лицензии уже есть аккаунт. Войди под своим логином.' })
        end

        local taken = MySQL.query.await('SELECT id FROM bu_accounts WHERE username = ? LIMIT 1', { username })
        if taken and taken[1] then
            return cb({ ok = false, message = 'Этот логин уже занят.' })
        end

        MySQL.insert('INSERT INTO bu_accounts (license, username, password) VALUES (?, ?, SHA2(CONCAT(?, ?, ?), 256))', {
            license, username, username, ':', password
        })

        Player(src).state:set('buAuthed', true, true)
        return cb({ ok = true })
    end

    if mode == 'login' then
        local account = MySQL.query.await('SELECT id FROM bu_accounts WHERE username = ? AND password = SHA2(CONCAT(?, ?, ?), 256) LIMIT 1', {
            username, username, ':', password
        })

        if not account or not account[1] then
            registerFail(license)
            return cb({ ok = false, message = 'Неверный логин или пароль.' })
        end

        attempts[license] = nil
        Player(src).state:set('buAuthed', true, true)
        return cb({ ok = true })
    end

    cb({ ok = false, message = 'Неизвестное действие.' })
end)
