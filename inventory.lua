-- inventory.lua
local globals = require("globals")
local utils = require("utils")


local function moveFromStorage(name, count, isFluid, target)
    local resource = { name = name, count = count }

    if (resource.count <= 0) then return 0 end

    local result = nil
    if isFluid then
        result = globals.rs.exportFluidToPeripheral(resource, target)
    else
        result = globals.rs.exportItemToPeripheral(resource, target)
    end
    return result or 0
end

local function moveToStorage(name, count, isFluid, target)
    local resource = { name = name, count = count }

    if (resource.count <= 0) then return 0 end

    local result = nil
    if isFluid then
        result = globals.rs.importFluidFromPeripheral(resource, target)
    else
        result = globals.rs.importItemFromPeripheral(resource, target)
    end
    return result or 0
end

local function getResourceInfo(name, isFluid, target)
    if not target then
        -- get the amount of the resource in the system
        if not isFluid then
            local item = globals.rs.getItem(name)
            if not item then return { name = name, count = 0, type = globals.quotaTypes.item, isCraftable = false } end
            return {
                name = item.name,
                count = item.count,
                type = globals.quotaTypes.item,
                isCraftable = item
                    .isCraftable
            }
        else
            local fluid = globals.rs.getFluid(name)
            if not fluid then return { name = name, count = 0, type = globals.quotaTypes.fluid, isCraftable = false } end
            return {
                name = fluid.name,
                count = fluid.count,
                type = globals.quotaTypes.fluid,
                isCraftable = fluid
                    .isCraftable
            }
        end
    end

    local targetPeripheral = globals.rs.wrap(target)
    if not targetPeripheral then
        return {
            name = name,
            count = 0,
            type = isFluid and globals.quotaTypes.fluid or
                globals.quotaTypes.item,
            isCraftable = false
        }
    end

    if isFluid then
        -- target is create fluid tank
        local fluidInfo = targetPeripheral.getInfo()
        if not fluidInfo then return { name = name, count = 0, type = globals.quotaTypes.fluid, isCraftable = false } end
        return {
            name = fluidInfo.name,
            count = fluidInfo.amount,
            type = globals.quotaTypes.fluid,
            isCraftable = false
        }
    else
        -- taget is inventory
        local itemList = targetPeripheral.list()
        local count = 0
        for _, item in pairs(itemList) do
            if item.name == name then
                count = count + item.count
            end
        end
        return {
            name = name,
            count = count,
            type = globals.quotaTypes.item,
            isCraftable = false
        }
    end
end

local function fillStation(station)
    for _, value in pairs(station.inputItems or {}) do
        local itemInfo = getResourceInfo(value.name, false, value.inventory)
        local moveCount = value.count - itemInfo.count
        moveFromStorage(value.name, moveCount, false, value.inventory)
    end

    for _, value in pairs(station.inputFluids or {}) do
        local fluidInfo = getResourceInfo(value.name, true, value.inventory)
        local moveCount = value.count - fluidInfo.count
        moveFromStorage(value.name, moveCount, true, value.inventory)
    end
end

local function emptyStation(station)
    for _, value in pairs(station.outputItems or {}) do
        local currentItemInfo = getResourceInfo(value.name, false)
        local itemQuota = (globals.quota[value.name].count or 0)

        if currentItemInfo.count < itemQuota then
            local moveCount = itemQuota - currentItemInfo.count
            moveToStorage(value.name, moveCount, false, value.inventory)
        end
    end

    for _, value in pairs(station.outputFluids or {}) do
        local currentFluidInfo = getResourceInfo(value.name, true)
        local fluidQuota = (globals.quota[value.name].count or 0)

        if currentFluidInfo.count < fluidQuota then
            local moveCount = fluidQuota - currentFluidInfo.count
            moveToStorage(value.name, moveCount, true, value.inventory)
        end
    end
end




local function runInventory()
    -- Access shared variables like globals.quota
    while true do
        for _, station in pairs(globals.providers) do
            emptyStation(station)
        end

        for key, value in pairs(globals.quota) do
            if value.type == globals.quotaTypes.item then
                local itemInfo = getResourceInfo(key, false)
                if itemInfo.isCraftable and not globals.rs.isItemCrafting({ name = value.name }) then
                    globals.rs.craftItem { name = value.name, count = value.count - itemInfo.count }
                end
                if itemInfo.count < value.count then
                    for _, station in pairs((globals.stationsByOutput[key] or {})) do
                        fillStation(station)
                        emptyStation(station)
                    end
                end
            else
                local fluidInfo = getResourceInfo(key, true)
                if fluidInfo.count < value.count then
                    for _, station in pairs((globals.stationsByOutput[key] or {})) do
                        fillStation(station)
                        emptyStation(station)
                    end
                end
            end
        end

        for _, station in pairs(globals.requesters) do
            fillStation(station)
        end
        os.sleep(1) -- To prevent excessive CPU usage
    end
end

local function addQuota(name, count, isFluid)
    globals.quota[name] = {
        name = name,
        count = count,
        type = isFluid and globals.quotaTypes.fluid or
            globals.quotaTypes.item
    }
    utils.store("quotas", globals.quota)
end

local function removeQuota(name)
    globals.quota[name] = nil
    utils.store("quotas", globals.quota)
end

local function addStation(station)
    globals.stations[station.senderID] = station

    local hasInput = station.inputItems or station.inputFluids
    local hasOutput = station.outputItems or station.outputFluids

    if (hasInput and hasOutput) then
        globals.processors[station.senderID] = station
    elseif (hasInput) then
        globals.requesters[station.senderID] = station
    else
        globals.providers[station.senderID] = station
    end

    if hasInput then
        for _, item in pairs(station.inputItems or {}) do
            local entry = globals.stationsByInput[item.name]
            if not entry then
                globals.stationsByInput[item.name] = { station }
            else
                table.insert(globals.stationsByInput[item.name], station)
            end
            if (not globals.quota[item.name]) then
                addQuota(item.name, 0, false)
            end
        end

        for _, item in pairs(station.inputFluids or {}) do
            local entry = globals.stationsByInput[item.name]
            if not entry then
                globals.stationsByInput[item.name] = { station }
            else
                table.insert(globals.stationsByInput[item.name], station)
            end

            if (not globals.quota[item.name]) then
                addQuota(item.name, 0, true)
            end
        end
    end

    if hasOutput then
        for _, item in pairs(station.outputItems or {}) do
            local entry = globals.stationsByOutput[item.name]
            if not entry then
                globals.stationsByOutput[item.name] = { station }
            else
                table.insert(globals.stationsByOutput[item.name], station)
            end

            if (not globals.quota[item.name]) then
                addQuota(item.name, 0, false)
            end
        end

        for _, item in pairs(station.outputFluids or {}) do
            local entry = globals.stationsByOutput[item.name]
            if not entry then
                globals.stationsByOutput[item.name] = { station }
            else
                table.insert(globals.stationsByOutput[item.name], station)
            end

            if (not globals.quota[item.name]) then
                addQuota(item.name, 0, true)
            end
        end
    end
end



return {
    runInventory = runInventory,
    addQuota = addQuota,
    addStation = addStation,
    removeQuota = removeQuota
}
