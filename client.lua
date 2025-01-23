local QBCore = exports['qb-core']:GetCoreObject()
local display = false

-- NUI'yi aç/kapat
local function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    
    if bool then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            local currentPlate = GetVehicleNumberPlateText(vehicle)
            SendNUIMessage({
                type = "openUI",
                currentPlate = currentPlate
            })
        end
    else
        SendNUIMessage({
            type = "closeUI"
        })
    end
end

-- Araç kontrollerini tek fonksiyonda topla
local function CheckVehicleConditions()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Bir araç içinde olmalısın!', 'error')
        return false
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('Sürücü koltuğunda olmalısın!', 'error')
        return false
    end
    
    return vehicle
end

-- exports fonksiyonunu güncelle
exports('platechanger', function(data, slot)
    local vehicle = CheckVehicleConditions()
    if vehicle then
        SetDisplay(true)
    end
end)

-- NUI Callback'leri
RegisterNUICallback('closeUI', function()
    SetDisplay(false)
end)

RegisterNUICallback('errorMessage', function(data)
    QBCore.Functions.Notify(data.message, 'error')
end)

RegisterNUICallback('savePlate', function(data)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    
    local oldPlate = GetVehicleNumberPlateText(vehicle)
    local newPlate = data.plate
    
    -- Önce plaka kontrolü yap
    TriggerServerEvent('plate-changer:server:checkPlate', newPlate)
end)

-- Server'dan plaka onayı geldiğinde
RegisterNetEvent('plate-changer:client:plateAvailable', function(newPlate)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    
    local oldPlate = GetVehicleNumberPlateText(vehicle)
    
    -- Plakayı güncelle
    SetVehicleNumberPlateText(vehicle, newPlate)
    
    -- Server'a bildir
    TriggerServerEvent('plate-changer:server:updatePlate', oldPlate, newPlate)
    
    -- NUI'yi kapat
    SetDisplay(false)
end)
