local QBCore = exports['qb-core']:GetCoreObject()

-- Araç kontrollerini tek fonksiyonda topla
local function CheckVehicleConditions()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        lib.notify({
            title = 'Hata',
            description = 'Bir araç içinde olmalısın!',
            type = 'error'
        })
        return false
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        lib.notify({
            title = 'Hata',
            description = 'Sürücü koltuğunda olmalısın!',
            type = 'error'
        })
        return false
    end
    
    return vehicle
end

-- Item kullanım exportları
QBCore.Functions.CreateUseableItem("platechanger", function(source)
    local vehicle = CheckVehicleConditions()
    if vehicle then
        local currentPlate = GetVehicleNumberPlateText(vehicle)
        local input = lib.inputDialog('Plaka Değiştirme', {
            {
                type = 'input',
                label = 'Yeni Plaka',
                placeholder = currentPlate,
                required = true,
                min = 3,
                max = 7
            }
        })

        if input then
            TriggerServerEvent('changer:server:checkPlate', input[1])
        end
    end
end)

QBCore.Functions.CreateUseableItem("phonechanger", function(source)
    local Player = QBCore.Functions.GetPlayer()
    local input = lib.inputDialog('Telefon Numarası Değiştirme', {
        {
            type = 'input',
            label = 'Yeni Numara',
            placeholder = Player.PlayerData.phone,
            required = true,
            min = 7,
            max = 9
        }
    })

    if input then
        TriggerServerEvent('changer:server:checkPhone', input[1])
    end
end)

-- Server'dan plaka onayı geldiğinde
RegisterNetEvent('changer:client:plateAvailable', function(newPlate)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    
    local oldPlate = GetVehicleNumberPlateText(vehicle)
    
    -- Plakayı güncelle
    SetVehicleNumberPlateText(vehicle, newPlate)
    
    -- Server'a bildir
    TriggerServerEvent('changer:server:updatePlate', oldPlate, newPlate)
end)
