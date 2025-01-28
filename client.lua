local QBCore = exports['qb-core']:GetCoreObject()

local IsBusy = false

-- Use Plate Changer Item
RegisterNetEvent('platechanger:client:UsePlateChanger', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Check if player is in driver seat
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('You must be in the driver seat!', 'error')
        return
    end

    if vehicle == 0 then
        QBCore.Functions.Notify('No vehicle found!', 'error')
        return
    end

    local currentPlate = QBCore.Functions.GetPlate(vehicle)
    if not currentPlate then return end

    -- Check vehicle ownership via server
    QBCore.Functions.TriggerCallback('platechanger:server:CheckOwnership', function(isOwned)
        if not isOwned then
            QBCore.Functions.Notify('This vehicle is not yours!', 'error')
            return
        end

        -- Open plate input dialog
        local input = lib.inputDialog('New License Plate', {
            {type = 'input', label = 'Plate (3-7 alphanumeric)', required = true, min = 3, max = 7}
        })

        if not input then return end
        local newPlate = string.upper(input[1]):gsub('%s+', '') -- Remove spaces

        -- Validate plate format
        if not string.match(newPlate, '^[A-Z0-9]+$') then
            QBCore.Functions.Notify('Invalid plate format!', 'error')
            return
        end

        if #newPlate < 3 or #newPlate > 7 then
            QBCore.Functions.Notify('Plate must be 3-7 characters!', 'error')
            return
        end

        -- Proceed to server
        TriggerServerEvent('platechanger:server:ChangePlate', currentPlate, newPlate)
    end, currentPlate)
end)

-- Apply new plate to vehicle
RegisterNetEvent('platechanger:client:ApplyNewPlate', function(oldPlate, newPlate)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if not vehicle or GetVehicleNumberPlateText(vehicle) ~= oldPlate then return end

    SetVehicleNumberPlateText(vehicle, newPlate)
    -- Optionally refresh vehicle in QBCore
    TriggerEvent('qb-vehiclekeys:client:SetOwner', newPlate)
end)