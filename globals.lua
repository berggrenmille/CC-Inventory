-- globals.lua
local utils = require("utils")

local globals = {
    error = "",
    providers = {},                   -- List of provider stations
    processors = {},                  -- List of processor stations
    requesters = {},                  -- List of requester stations
    stations = {},                    -- List of all stations

    rs = peripheral.find("rsBridge"), -- Refined storage peripheral
    modem = peripheral.find("modem"), -- Modem peripheral
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
