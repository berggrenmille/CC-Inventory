-- Import required modules
local globals = require("globals")
local inventory = require("inventory")
local gui = require("gui")

-- Function to handle incoming messages from clients
local function handleClientMessage(senderID, message)
    -- Ensure the message is a table and has expected keys
    if type(message) == "table" and message.action == "register" and message.station then
        message.station.senderID = senderID
        inventory.addStation(message.station)
    else
        gui.debugPrint("Received invalid message from client " .. senderID)
    end
end

-- Function to run the Rednet network
local function runNetwork()
    -- Check if the modem is present
    if not peripheral.wrap(globals.modemSide) then
        error("Modem not found. Please ensure a wireless modem exists")
    end

    -- Open Rednet using the specified modem
    rednet.open(globals.modemSide)
    rednet.host(globals.protocol, globals.host)
    gui.debugPrint("Rednet started on modem: " .. tostring(globals.modemSide))

    -- Main loop to listen for incoming messages
    while true do
        -- Wait for incoming messages with a timeout (optional, to allow non-blocking checks)
        local senderID, message, protocol = rednet.receive("inventoryComm")

        -- If a message is received, handle it
        if senderID then
            handleClientMessage(senderID, message)
        end

        -- Optional: Other periodic tasks or checks can be placed here
        -- Example: You could handle clean-up or maintenance tasks every loop cycle.
        os.sleep(0.1) -- Adjust sleep to control how often checks occur
    end
end

-- Return the runNetwork function to be used externally
return {
    runNetwork = runNetwork
}
