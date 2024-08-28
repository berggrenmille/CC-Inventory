-- inventory.lua
local globals = require("globals")

local function moveItemFromStorage(name, amount, station)
    local item = { name = name, amount = amount }
    local target = nil
    for index, value in ipairs(station.inputItems) do
        if value.name == name then
            target = value.inventory
            break
        end
    end
    local result = globals.rs.exportItemToPeripheral(item, target)
    if result == nil then
        print("Failed to move item from storage")
    end
end

local function moveFluidFromStorage(name, count, station)
    local fluid = { name = name, count = count }
    local target = nil
    for index, value in ipairs(station.inputFluids) do
        if value.name == name then
            target = value.inventory
            break
        end
    end
    local result = globals.rs.exportFluidToPeripheral(fluid, target)
    if result == nil then
        print("Failed to move fluid from storage")
    end
end

local function checkItem(thing, expected)
    local item = globals.rs.getItem(thing)
    if item == nil then
        return
    end
    local amount = item.amount

    if amount > expected then return end

    -- Find a provider station with the item
    for _, station in ipairs(globals.providers) do
        if station:hasItem(item) then
            station:provideItem(item)
            break
        end
    end
end

local function checkFluid(fluid, expected)
end

local function checkQuota()
    for thing, target in pairs(globals.quota) do
        if thing.type == globals.quotaTypes.item then -- Item quota
            checkItem(thing)
        else
            checkFluid(thing)
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

return {
    runInventory = runInventory
}
