Config = Config or {}

-- Модель для кассира/крупье (деловая, одетая)
Config.ClerkModel = 'a_m_y_business_01'
Config.DealerModel = 's_m_m_highsec_01'

-- Банки: кассиры у стоек
Config.BankLocations = {
    vector3(149.05, -1041.3, 29.37),
    vector3(313.32, -280.03, 54.17),
    vector3(-351.94, -50.72, 49.04),
    vector3(-1212.68, -331.83, 37.78),
    vector3(-2961.67, 482.31, 15.7),
    vector3(1175.64, 2707.71, 38.09),
    vector3(247.65, 223.87, 106.29),
    vector3(-111.98, 6470.56, 31.63)
}

-- Казино: крупье
Config.Casino = {
    model = 's_m_m_highsec_01',
    coords = vector3(928.0, 47.0, 81.0)
}
