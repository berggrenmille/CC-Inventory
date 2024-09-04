-- globals.lua
local utils = require("utils")

local globals = {
    error = "",
    providers = {},                   -- List of provider stations
    processors = {},                  -- List of processor stations
    requesters = {},                  -- List of requester stations
    stations = {},                    -- List of all stations

    rs = peripheral.find("rsBridge"), -- Refined storage peripheral
    modemSide = "top",                -- Side of the modem
    protocol = "inventoryComm",
    host = "inventoryServer",
    stationTypes = {
        provider = "provider",
        processor = "processor",
        requester = "requester"
    },
    quotaTypes = {
        item = "item",
        fluid = "fluid"
    },
    quota = utils.load("quotas") -- Shared quotas for items
}

return globals
