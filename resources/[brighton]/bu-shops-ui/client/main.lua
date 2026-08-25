local menuOpen = false

local function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'bu:shops:close' })
end

RegisterNetEvent('bu-shops-ui:client:open', function(shop, label, items)
    menuOpen = true
    SendNUIMessage({ type = 'bu:shops:open', shop = shop, label = label, items = items })
    SetNuiFocus(true, true)
end)

-- ESC закрывает меню, даже когда NuiFocus перехватывает клавиши
CreateThread(function()
    while true do
        Wait(0)
        if menuOpen and IsControlJustPressed(0, 202) then
            closeMenu()
        end
    end
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('qb-shops:server:buyProduct', {
        shop = data.shop,
        slot = data.slot,
        amount = tonumber(data.amount) or 1,
        payment = data.payment
    })
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb('ok')
end)
