-- Install libraries

local globals = require("globals")
local inventory = require("inventory")
--local network = require("network")
local gui = require("gui")

parallel.waitForAny(
    function() inventory.runInventory() end,
    function() gui.runGui() end
)


-- log something when wrong
print("Done")
print("error: ", globals.error)
