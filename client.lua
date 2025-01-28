local QBCore = exports['qb-core']:GetCoreObject()

local IsBusy = false

RegisterNetEvent('platechanger:client:UsePlateChanger', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('Sürücü koltuğunda olmalısın!', 'error')
        return
    end

    if vehicle == 0 then
        QBCore.Functions.Notify('Araç bulunamadı!', 'error')
        return
    end

    local currentPlate = QBCore.Functions.GetPlate(vehicle)
    if not currentPlate then return end

    QBCore.Functions.TriggerCallback('platechanger:server:CheckOwnership', function(isOwned)
        if not isOwned then
            QBCore.Functions.Notify('Bu araç size ait değil!', 'error')
            return
        end

        local input = lib.inputDialog('Yeni Plaka', {
            {type = 'input', label = 'Plaka (3-7 karakter)', required = true, min = 3, max = 7}
        })

        if not input then return end
        local newPlate = string.upper(input[1]):gsub('%s+', '')

        if not string.match(newPlate, '^[A-Z0-9]+$') then
            QBCore.Functions.Notify('Geçersiz plaka formatı!', 'error')
            return
        end

        if #newPlate < 3 or #newPlate > 7 then
            QBCore.Functions.Notify('Plaka 3-7 karakter olmalı!', 'error')
            return
        end

        TriggerServerEvent('platechanger:server:ChangePlate', currentPlate, newPlate)
    end, currentPlate)
end)

RegisterNetEvent('platechanger:client:ApplyNewPlate', function(oldPlate, newPlate)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if not vehicle or GetVehicleNumberPlateText(vehicle) ~= oldPlate then return end

    SetVehicleNumberPlateText(vehicle, newPlate)
    TriggerEvent('qb-vehiclekeys:client:SetOwner', newPlate)
end)