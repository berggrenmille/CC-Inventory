local modemside = "top"
local channel = 5

local stationinfo = {
    name = "station1",
    inputItems = {
        { name = "minecraft:stone",      amount = 64 },
        { name = "minecraft:iron_ingot", amount = 64 }
    },
    outputItems = {
        { name = "minecraft:stone",      amount = 64 },
        { name = "minecraft:iron_ingot", amount = 64 }
    },
    inputFluids = {
        { name = "minecraft:water", count = 1000 }
    },
    outputFluids = {
        { name = "minecraft:water", count = 1000 }
    }
}

local message = {
    action = "register",
    station = stationinfo
}

rednet.open(modemside)
local serverId = rednet.lookup("inventoryComm", "inventoryServer")
rednet.send(serverId, message, "inventoryComm")
