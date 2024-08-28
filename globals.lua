-- globals.lua
local globals = {
    error = "",
    quota = {},                         -- Shared quotas for items
    providers = {},                     -- List of provider stations
    processors = {},                    -- List of processor stations
    requesters = {},                    -- List of requester stations

    rs = peripheral.wrap("rsBridge_0"), -- Refined storage peripheral
    modem = peripheral.wrap("top"),     -- Modem peripheral
    stationTypes = {
        provider = "provider",
        processor = "processor",
        requester = "requester"
    },
    quotaTypes = {
        item = "item",
        fluid = "fluid"
    }
}

return globals
