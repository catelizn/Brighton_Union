Config = Config or {}

-- Бизнесы, которые покупаются через маркер
Config.Properties = {
    ['lsc_1']    = { label = 'Автомастерская LSC',     coords = vector3(731.81, -1088.83, 22.17),  price = 2500000 },
    ['lsc_2']    = { label = 'Автомастерская LSC',     coords = vector3(-337.79, -136.93, 39.01),  price = 2500000 },
    ['lsc_3']    = { label = 'Автомастерская LSC',     coords = vector3(-1155.45, -2007.58, 13.18), price = 2500000 },
    ['lsc_4']    = { label = 'Автомастерская LSC',     coords = vector3(1174.82, 2640.72, 37.79),   price = 2500000 },
    ['shop_247'] = { label = 'Магазин 24/7',           coords = vector3(26.45, -1315.51, 29.62),    price = 1500000 },
    ['carwash']  = { label = 'Автомойка',              coords = vector3(55.7, -1391.0, 29.4),       price = 900000 },
    ['petrol']   = { label = 'Заправка LTD',           coords = vector3(-47.02, -1758.23, 29.42),   price = 1800000 }
}

Config.BuyLabel = 'Купить бизнес'
Config.SellLabel = 'Продать государству'
Config.StateRefundPercent = 0.5

-- Товары: владелец заказывает поставку, дальнобойщик привозит, владелец продаёт
Config.Supply = {
    orderPricePerUnit = 400,  -- цена закупки у поставщика (со счёта банка)
    sellPricePerUnit = 500,   -- цена продажи товаров (на счёт банка)
    maxUnitsPerOrder = 20
}
