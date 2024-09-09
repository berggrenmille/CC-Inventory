local modemside = "top"
local channel = 5

local stationinfo = {
    name = "station1",
    inputItems = {
        { name = "minecraft:stone", amount = 64 },
    },
    outputItems = nil,
    inputFluids = nil,
    outputFluids = nil
}

local message = {
    action = "register",
    station = stationinfo
}

rednet.open(modemside)


while true do
    local serverId = rednet.lookup("inventoryComm", "inventoryServer")
    rednet.send(serverId, message, "inventoryComm")
    os.sleep(60)
end
