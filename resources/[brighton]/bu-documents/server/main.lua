local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bu-documents:server:takePhoto', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local metadata = Player.PlayerData.metadata or {}
    metadata.photodate = os.date('%d.%m.%Y %H:%M')

    Player.Functions.SetPlayerData(src, 'metadata', metadata)
    TriggerClientEvent('bu-documents:client:photoTaken', src)
end)
