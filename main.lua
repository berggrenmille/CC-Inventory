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


-- log something when wrong
print("Done")
print("error: ", globals.error)
