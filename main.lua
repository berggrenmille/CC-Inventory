-- Install libraries

local globals = require("globals")
local inventory = require("inventory")
local network = require("network")
local gui = require("basalt_gui")

parallel.waitForAny(
    function() inventory.runInventory() end,
    function() network.runRednet() end,
    function() gui.runGui() end
)


local modem
local rs -- refined storage peripheral (rs bridge)


local typeExample = "provider"|"processor"|"requester"
-- provider: provides items without input
-- processor: processes input and provides output
-- requester: requests items without output

-- FLUID {name, count}
-- ITEM  {name, amount}

-- example station which a station will register
local exampleProcessor = {
    name = "Example processor",
    type = "processor",
    inputItems = {
        {
            name = "example:example_item",
            inventory = "minecraft:chest_52",
            amount = 64

        },
        {
            name = "example:example_item2",
            inventory = "minecraft:chest_53",
            amount = 8
        }
    },
    inputFluids = {
        {
            name = "example:example_fluid",
            inventory = "fluidTank_52",
            count = 10000
        }
    },
    outputItems =
        {
            name = "example:example_item3",
            inventory = "minecraft:chest_54"
        } | nil,

    isOutputOnly = function(self)
        return self.input == nil
    end
}

-- Holds quotas for certain items, if quota is not reached, go trough available stations and provide the input for the station with right output
local quota = {}
-- list of stations
local stations = {}

-- Inventory service
local function runInventory()

end

-- Rednet service
local function runRednet()

end

-- GUI service
local function runGui()

end

parallel.waitForAny(runInventory, runRednet, runGui)

-- log something when wrong
print(error)
