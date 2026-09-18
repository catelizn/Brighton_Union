Config = Config or {}

-- Доступ к MDT только у этих работ
Config.PoliceJobs = { 'police', 'sheriff' }

-- Уровни ордера (розыск)
Config.WarrantLevels = {
    { key = 'low',    label = 'Низкий',   color = 2 },
    { key = 'medium', label = 'Средний',  color = 1 },
    { key = 'high',   label = 'Высокий',  color = 3 }
}
