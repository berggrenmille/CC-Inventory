-- inventory.lua
local globals = require("globals")
local utils = require("utils")

local function addFluidQuota(name, amount)
    local fluid = { name = name, amount = amount, type = globals.quotaTypes.fluid }
    globals.quota[name] = fluid
    utils.store("quotas", globals.quota)
end

local function addItemQuota(name, amount)
    local item = { name = name, amount = amount, type = globals.quotaTypes.item }
    globals.quota[name] = item
    utils.store("quotas", globals.quota)
end

local function moveItemFromStorage(name, amount, station)
    local item = { name = name, amount = amount }
    local target = nil
    for _, value in pairs(station.inputItems) do
        if value.name == name then
            target = value.inventory
            item.amount = value.amount - amount
            break
        end
    end
    if (item.amount <= 0) then return end
    local result = globals.rs.exportItemToPeripheral(item, target)
    if not result then
        print("Failed to move item from storage")
    end
end

local function moveItemToStorage(name, amount, station)
    utils.debugPrint("Moving item to storage: " .. name .. " with amount: " .. amount)
    local item = { name = name, amount = amount }
    local target = nil
    for _, value in pairs(station.outputItems) do
        if value.name == name then
            utils.debugPrint("Found item in station: " .. station.name)
            target = value.inventory
            break
        end
    end
    local result = globals.rs.importItemFromPeripheral(item, target)
    utils.debugPrint("Result: " .. tostring(result))
    if not result then
        print("Failed to move item to storage")
    end
end

local function moveFluidFromStorage(name, count, station)
    local fluid = { name = name, count = count }
    local target = nil
    for _, value in pairs(station.inputFluids) do
        if value.name == name then
            target = value.inventory
            break
        end
    end
    local result = globals.rs.exportFluidToPeripheral(fluid, target)
    if not result then
        print("Failed to move fluid from storage")
    end
end

local function moveFluidToStorage(name, count, station)
    local fluid = { name = name, count = count }
    local target = nil
    for _, value in pairs(station.outputFluids) do
        if value.name == name then
            target = value.inventory
            break
        end
    end
    local result = globals.rs.importFluidFromPeripheral(fluid, target)
    if not result then
        print("Failed to move fluid to storage")
    end
end

local function fillStation(station)
    for _, value in pairs(station.inputItems) do
        local inventory = peripheral.wrap(value.inventory)
        if not inventory then
            print("Failed to wrap peripheral: " .. value.inventory .. " : " .. station.name)
            break
        end
        local itemInfo = inventory.getItemDetail(value.name)
        local currentAmount
        if not itemInfo then
            currentAmount = 0
        else
            currentAmount = itemInfo.count
        end
        moveItemFromStorage(value.name, value.amount - currentAmount, station)
    end

    for _, value in pairs(station.inputFluids) do
        local inventory = peripheral.wrap(value.inventory)
        if not inventory then
            print("Failed to wrap peripheral: " .. value.inventory .. " : " .. station.name)
            break
        end
        local fluidInfo = inventory.getInfo()
        local currentAmount
        if not fluidInfo then
            currentAmount = 0
        else
            currentAmount = fluidInfo.amount
        end
        moveFluidFromStorage(value.name, value.count - currentAmount, station)
    end
end

local function checkItem(thing, expected)
    utils.debugPrint("Checking item: " .. thing .. " with expected amount: " .. expected)
    local item = globals.rs.getItem({ name = thing })
    if not item then
        return
    end
    local amount = item.amount

    utils.debugPrint("Current amount: " .. amount)

    if amount > expected then
        return
    end
    -- Find a provider station with the item
    for id, station in pairs(globals.providers) do
        utils.debugPrint("Checking provider station: " .. station.name)
        for _, item in pairs(station.outputItems) do
            if item.name == thing then
                utils.debugPrint("Found item in provider station: " .. station.name)
                moveItemToStorage(thing, expected - amount, station)
                if globals.rs.getItem({ name = thing }).amount >= expected then
                    return
                end
            end
        end
    end

    -- Find a processor station with the item
    for _, station in pairs(globals.processors) do
        utils.debugPrint("Checking processor station: " .. station.name)
        for _, item in pairs(station.outputItems) do
            if item.name == thing then
                utils.debugPrint("Found item in processor station: " .. station.name)
                -- move output items to storage
                moveItemToStorage(thing, expected - amount, station)
                -- return if we have enough items
                if globals.rs.getItem({ name = thing }).amount >= expected then
                    return
                end
                -- fill the processor with input items
                fillStation(station)
                break
            end
        end
    end
end

local function getFluid(name)
    local fluids = globals.rs.listFluids()
    for _, fluid in pairs(fluids) do
        if fluid.name == name then
            return fluid
        end
    end
end

local function checkFluid(thing, expected)
    local fluid = getFluid(thing.name)
    if not fluid then
        return
    end
    local amount = fluid.amount

    if amount > expected then return end

    -- Find a provider station with the fluid
    for _, station in pairs(globals.providers) do
        for _, item in pairs(station.outputFluids) do
            if item.name == thing.name then
                moveFluidToStorage(thing.name, expected - amount, station)
                if getFluid(thing.name).amount >= expected then
                    return
                end
            end
        end
    end

    -- Find a processor station with the fluid
    for _, station in pairs(globals.processors) do
        for _, item in pairs(station.outputFluids) do
            if item.name == fluid.name then
                -- move output items to storage
                moveFluidToStorage(thing.name, expected - amount, station)
                -- return if we have enough items
                if getFluid(thing.name).amount >= expected then
                    return
                end
                -- fill the processor with input items
                fillStation(station)
                break
            end
        end
    end
end

local function checkQuota()
    for key, value in pairs(globals.quota) do
        if value.type == globals.quotaTypes.item then -- Item quota
            checkItem(key, value.amount)
        else
            checkFluid(key, value.amount)
        end
    end
end

local function runInventory()
    -- Access shared variables like globals.quota
    while true do
        -- Check if the quota is reached
        checkQuota()
        os.sleep(1) -- To prevent excessive CPU usage
    end
end

local function addStation(station)
    globals.stations[station.senderID] = station

    local hasInput = station.inputItems or station.inputFluids
    local hasOutput = station.outputItems or station.outputFluids

    utils.debugPrint("Adding station: " .. station.name .. " with senderID: " .. station.senderID)
    utils.debugPrint("Station has input: " .. tostring(hasInput))
    utils.debugPrint("Station has output: " .. tostring(hasOutput))


    if (hasInput and hasOutput) then
        globals.processors[station.senderID] = station
    elseif (hasInput) then
        globals.requesters[station.senderID] = station
    else
        globals.providers[station.senderID] = station
    end
end

return {
    runInventory = runInventory,
    addFluidQuota = addFluidQuota,
    addItemQuota = addItemQuota,
    addStation = addStation
}
