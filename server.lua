local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('changer:server:updatePlate', function(oldPlate, newPlate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end

    MySQL.update('UPDATE player_vehicles SET plate = ?, mods = JSON_SET(mods, "$.plate", ?) WHERE plate = ? AND citizenid = ?', {
        newPlate,
        newPlate,
        oldPlate,
        Player.PlayerData.citizenid
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Başarılı',
                description = 'Plaka başarıyla güncellendi!',
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Hata',
                description = 'Plaka güncellenirken bir hata oluştu!',
                type = 'error'
            })
        end
    end)
end)

RegisterNetEvent('changer:server:updatePhone', function(oldNumber, newNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end

    MySQL.update('UPDATE players SET phone = ? WHERE citizenid = ?', {
        newNumber,
        Player.PlayerData.citizenid
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Telefon numarası başarıyla güncellendi!', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Telefon numarası güncellenirken bir hata oluştu!', 'error')
        end
    end)
end)

local function IsValidPlate(plate)
    return string.match(plate, "^[A-Z0-9]{3,7}$") ~= nil
end

local function IsValidPhone(phone)
    return string.match(phone, "^[0-9]{7,9}$") ~= nil
end

RegisterNetEvent('changer:server:checkPlate', function(plate)
    local src = source
    
    if not IsValidPlate(plate) then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz plaka formatı!', 'error')
        return
    end
    
    MySQL.scalar('SELECT 1 FROM player_vehicles WHERE plate = ?', {plate}, function(exists)
        if exists then
            TriggerClientEvent('QBCore:Notify', src, 'Bu plaka zaten kullanımda!', 'error')
        else
            TriggerClientEvent('changer:client:plateAvailable', src, plate)
        end
    end)
end)

RegisterNetEvent('changer:server:checkPhone', function(phone)
    local src = source
    
    if not IsValidPhone(phone) then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz telefon numarası formatı!', 'error')
        return
    end
    
    MySQL.scalar('SELECT 1 FROM players WHERE phone = ?', {phone}, function(exists)
        if exists then
            TriggerClientEvent('QBCore:Notify', src, 'Bu telefon numarası zaten kullanımda!', 'error')
        else
            TriggerClientEvent('changer:client:phoneAvailable', src, phone)
        end
    end)
end)

CreateThread(function()
    QBCore.Commands.Add('ck', 'Karakter silme komutu', {{name = 'id', help = 'Oyuncu ID'}}, true, function(source, args)
        local src = source
        local playerId = args[1]
        local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if Player then
            local citizenid = Player.PlayerData.citizenid
            DropPlayer(playerId, 'Karakteriniz silindi.')
            CreateThread(function()
                Wait(200)
    
                exports.oxmysql:execute('DELETE FROM players WHERE citizenid = ?', { citizenid })
                exports.oxmysql:execute('DELETE FROM player_vehicles WHERE citizenid = ?', { citizenid })
                exports.oxmysql:execute('DELETE FROM player_outfits WHERE citizenid = ?', { citizenid })
                exports.oxmysql:execute('DELETE FROM player_houses WHERE citizenid = ?', { citizenid })
                exports.oxmysql:execute('DELETE FROM player_contacts WHERE citizenid =?', { citizenid })
                exports.oxmysql:execute('DELETE FROM playerskins WHERE citizenid =?', { citizenid })
                TriggerClientEvent("QBCore:Notify", src, "Karakter başarıyla silindi!")
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Oyuncu bulunamadı!', 'error')
        end
    end, 'god')
end)