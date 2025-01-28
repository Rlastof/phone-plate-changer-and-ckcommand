local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('platechanger', function(source)
    TriggerClientEvent('platechanger:client:UsePlateChanger', source)
end)

-- Check Vehicle Ownership
QBCore.Functions.CreateCallback('platechanger:server:CheckOwnership', function(source, cb, plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return cb(false) end

    local result = MySQL.Sync.fetchScalar(
        'SELECT 1 FROM player_vehicles WHERE citizenid = ? AND plate = ?',
        {player.PlayerData.citizenid, plate}
    )
    cb(result ~= nil)
end)

-- Change Plate
RegisterNetEvent('platechanger:server:ChangePlate', function(oldPlate, newPlate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    -- Check if new plate already exists
    local exists = MySQL.Sync.fetchScalar(
        'SELECT 1 FROM player_vehicles WHERE plate = ?',
        {newPlate}
    )
    if exists then
        QBCore.Functions.Notify(src, 'Bu plaka zaten kullanımda!', 'error')
        return
    end

    -- Update database
    MySQL.update('UPDATE player_vehicles SET plate = ? WHERE plate = ? AND citizenid = ?', {
        newPlate,
        oldPlate,
        player.PlayerData.citizenid
    }, function(rowsChanged)
        if rowsChanged > 0 then
            -- Update mods JSON
            MySQL.update(
                'UPDATE player_vehicles SET mods = JSON_SET(mods, "$.plate", ?) WHERE plate = ?',
                {newPlate, newPlate}
            )
            
            -- Update vehicle in-world plate
            TriggerClientEvent('platechanger:client:ApplyNewPlate', src, oldPlate, newPlate)
            QBCore.Functions.Notify(src, 'Plaka değiştirildi: '..newPlate, 'success')
        else
            QBCore.Functions.Notify(src, 'Plaka değiştirilemedi!', 'error')
        end
    end)
end)