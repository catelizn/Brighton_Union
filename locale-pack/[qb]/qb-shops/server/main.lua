local Bail = {}

-- Functions

local function checkTable(inputValue, requiredValue)
    if type(inputValue) == 'table' and type(requiredValue) == 'table' then
        for _, v in ipairs(requiredValue) do
            if inputValue[v] then return true end
        end
    elseif type(requiredValue) == 'table' then
        for _, v in ipairs(requiredValue) do
            if v == inputValue then return true end
        end
    elseif type(inputValue) == 'string' and type(requiredValue) == 'string' then
        return inputValue == requiredValue
    elseif type(inputValue) == 'table' and type(requiredValue) == 'string' then
        return inputValue[requiredValue] == true
    elseif type(inputValue) == 'string' and type(requiredValue) == 'table' then
        for _, v in ipairs(requiredValue) do
            if v == inputValue then return true end
        end
    end

    return false
end

local function saveShopInv(shop, products)
    local shopinv = {}
    shopinv[shop] = {}
    shopinv[shop].products = products
    SaveResourceFile(GetCurrentResourceName(), Config.ShopsInvJsonFile, json.encode(shopinv), -1)
end

local function deliveryPay(source, shop)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return end
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local deliverCoords = Config.Locations[shop].delivery
    local distance = #(playerCoords - vector3(deliverCoords.x, deliverCoords.y, deliverCoords.z))
    if distance > 10 then return end
    Player.AddMoney('bank', Config.DeliveryPrice, 'qb-shops:deliveryPay')
    if math.random(100) <= 10 then exports['qb-inventory']:AddItem(source, Config.RewardItem, 1, false, false, 'qb-shops:deliveryPay') end
end

-- Events

-- Deliveries

RegisterNetEvent('qb-shops:server:RestockShopItems', function(shop)
    local src = source
    if not shop then return end
    if not Config.Locations[shop] then return end
    deliveryPay(src, shop)
    if not Config.Locations[shop].useStock then return end
    local randAmount = math.random(10, 50)
    for k in pairs(Config.Locations[shop].products) do Config.Locations[shop].products[k].amount += randAmount end
    saveShopInv(shop, Config.Locations[shop].products)
    TriggerClientEvent('qb-shops:client:SetShopItems', -1, shop, Config.Locations[shop].products)
end)

RegisterNetEvent('qb-shops:server:UpdateShopItems', function(shop, itemData, amount) -- called from inventory
    if not shop or not itemData or not amount then return end
    if not Config.Locations[shop] then return end
    if not Config.Locations[shop].useStock then return end
    Config.Locations[shop].products[itemData.slot].amount -= amount
    if Config.Locations[shop].products[itemData.slot].amount < 0 then
        Config.Locations[shop].products[itemData.slot].amount = 0
    end
    saveShopInv(shop, Config.Locations[shop].products)
    TriggerClientEvent('qb-shops:client:SetShopItems', -1, shop, Config.Locations[shop].products)
end)

RegisterNetEvent('qb-shops:server:DoBail', function(bool)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if bool then
        if Player.RemoveMoney('cash', Config.TruckDeposit, 'tow-received-bail') then
            Bail[Player.PlayerData.citizenid] = Config.TruckDeposit
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.paid_with_cash', { value = Config.TruckDeposit }), 'success')
            TriggerClientEvent('qb-shops:client:SpawnVehicle', src)
        elseif Player.RemoveMoney('bank', Config.TruckDeposit, 'tow-received-bail') then
            Bail[Player.PlayerData.citizenid] = Config.TruckDeposit
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.paid_with_bank', { value = Config.TruckDeposit }), 'success')
            TriggerClientEvent('qb-shops:client:SpawnVehicle', src)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_deposit', { value = Config.TruckDeposit }), 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] then
            Player.AddMoney('cash', Bail[Player.PlayerData.citizenid], 'trucker-bail-paid')
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.refund_to_cash', { value = Config.TruckDeposit }), 'success')
        end
    end
end)

RegisterNetEvent('qb-shops:server:PaySlip', function(drops)
    local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local coords = Config.DeliveryLocations['main'].coords
    local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))
    if distance > 10 then return end
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    local completedDrops = tonumber(drops)
    if not drops then return end
    local payment = Config.DeliveryPrice * completedDrops
    Player.AddMoney('bank', payment, 'trucker-salary')
    Player.AddRep('delivery', completedDrops)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.you_earned', { value = payment }), 'success')

    TriggerEvent('bu-jobs:server:externalAction', src, 'trucker')
end)

-- Opening shops

RegisterNetEvent('qb-shops:server:openShop', function(data)
    local src = source
    local shopName = data.shop
    local shopData = Config.Locations[shopName]
    if not shopData then return end
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    local playerData = Player.PlayerData
    local products = shopData.products
    local items = {}

    if shopData.useStock then
        local shopInvJson = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.ShopsInvJsonFile))
        if shopInvJson[shopName] then
            for k, v in pairs(shopInvJson[shopName].products) do
                if products[k] then
                    products[k].amount = v.amount
                end
            end
        end
    end

    for i = 1, #products do
        local curProduct = products[i]
        local addProduct = true

        if curProduct.requiredGrade and playerData.job.grade.level < curProduct.requiredGrade then
            addProduct = false
        end

        if addProduct and curProduct.requiredJob and not checkTable(playerData.job.name, curProduct.requiredJob) then
            addProduct = false
        end

        if addProduct and curProduct.requiredGang and not checkTable(playerData.gang.name, curProduct.requiredGang) then
            addProduct = false
        end

        if addProduct and curProduct.requiredLicense and not checkTable(playerData.metadata['licences'], curProduct.requiredLicense) then
            addProduct = false
        end

        if addProduct then
            curProduct.slot = i
            -- В конфиге магазина есть только name: название и картинку берём
            -- из общей базы предметов (там они уже переведены)
            local sharedItem = QBCore.Shared.Items[curProduct.name]
            if sharedItem then
                curProduct.label = sharedItem.label
                curProduct.image = sharedItem.image
            end
            items[#items + 1] = curProduct
        end
    end

    TriggerClientEvent('bu-shops-ui:client:open', src, shopName, shopData.label, items)
end)

-- Покупка товара: вся валидация на сервере (цена, доступ, сток, деньги)
RegisterNetEvent('qb-shops:server:buyProduct', function(data)
    local src = source
    local shopName = data.shop
    local shopData = Config.Locations[shopName]
    if not shopData then return end

    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end

    local slot = tonumber(data.slot)
    local amount = tonumber(data.amount) or 1
    if not slot or amount < 1 or amount > 50 then return end

    local product = shopData.products[slot]
    if not product or product.slot ~= slot then return end

    -- Те же проверки доступа, что и при открытии магазина
    local playerData = Player.PlayerData
    if product.requiredGrade and playerData.job.grade.level < product.requiredGrade then return end
    if product.requiredJob and not checkTable(playerData.job.name, product.requiredJob) then return end
    if product.requiredGang and not checkTable(playerData.gang.name, product.requiredGang) then return end
    if product.requiredLicense and not checkTable(playerData.metadata['licences'], product.requiredLicense) then return end

    if shopData.useStock then
        if (product.amount or 0) < amount then
            TriggerClientEvent('QBCore:Notify', src, 'Товара нет в наличии.', 'error')
            return
        end
    end

    local total = math.floor((product.price or 0) * amount)
    if total <= 0 then return end

    local moneyType = data.payment == 'bank' and 'bank' or 'cash'
    if not Player.Functions.RemoveMoney(moneyType, total, 'shop-' .. shopName) then
        TriggerClientEvent('QBCore:Notify', src, 'Недостаточно средств.', 'error')
        return
    end

    local info = {}
    if product.info then
        if type(product.info) == 'table' then
            info = product.info
        else
            local decoded = json.decode(product.info)
            if decoded then info = decoded end
        end
    end

    exports['qb-inventory']:AddItem(src, product.name, amount, false, info, 'qb-shops:buyProduct')

    if shopData.useStock then
        product.amount = product.amount - amount
        saveShopInv(shopName, shopData.products)
        TriggerClientEvent('qb-shops:client:SetShopItems', -1, shopName, shopData.products)
    end

    TriggerClientEvent('QBCore:Notify', src, string.format('Куплено: %s ×%d за $%d.', product.label or product.name, amount, total), 'success')
end)
