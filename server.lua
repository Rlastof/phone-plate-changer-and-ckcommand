local QBCore = exports['qb-core']:GetCoreObject()

-- Plaka değiştirme eventi
RegisterNetEvent('plate-changer:server:updatePlate', function(oldPlate, newPlate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end

    -- Veritabanında plaka güncelleme
    MySQL.update('UPDATE player_vehicles SET plate = ?, mods = JSON_SET(mods, "$.plate", ?) WHERE plate = ? AND citizenid = ?', {
        newPlate,
        newPlate,
        oldPlate,
        Player.PlayerData.citizenid
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Başarılı güncelleme bildirimi
            TriggerClientEvent('QBCore:Notify', src, 'Plaka başarıyla güncellendi!', 'success')
        else
            -- Hata bildirimi
            TriggerClientEvent('QBCore:Notify', src, 'Plaka güncellenirken bir hata oluştu!', 'error')
        end
    end)
end)

-- Plaka format kontrolü ekle
local function IsValidPlate(plate)
    return string.match(plate, "^[A-Z0-9]{3,7}$") ~= nil
end

-- Plaka kontrolü
RegisterNetEvent('plate-changer:server:checkPlate', function(plate)
    local src = source
    
    if not IsValidPlate(plate) then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz plaka formatı!', 'error')
        return
    end
    
    MySQL.scalar('SELECT 1 FROM player_vehicles WHERE plate = ?', {plate}, function(exists)
        if exists then
            TriggerClientEvent('QBCore:Notify', src, 'Bu plaka zaten kullanımda!', 'error')
        else
            TriggerClientEvent('plate-changer:client:plateAvailable', src, plate)
        end
    end)
end)
