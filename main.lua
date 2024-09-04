-- Install libraries

local globals = require("globals")
local inventory = require("inventory")
local gui = require("gui")
local network = require("network")

parallel.waitForAny(
    function() inventory.runInventory() end,
    function() gui.runGui() end,
    function() network.runNetwork() end
)


-- log something when wrong
print("Done")
print("error: ", globals.error)
