-- basalt_gui.lua
local basalt = require("basalt")
local globals = require("globals")
local inventory = require("inventory")
local utils = require("utils")
local debugVar = false

local function debugPrint(...)
    if debug then
        basalt.debug(...)
    end
end

local function runGui()
    local main = basalt.createFrame() -- The main frame/most important frame in your project
    local button = main               --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton()                  --> This is an example of call chaining
        :setPosition(4, 4)
        :setText("Click me!")
        :onClick(
            function()
                basalt.debug("I got clicked!")
            end)

    basalt.autoUpdate()


    -- Display a welcome message
    print("Welcome to the Inventory Management System!")
    print("Available commands:")
    print("- AddFluid {name} {amount}: Adds a fluid quota to the inventory.")
    print("- AddItem {name} {amount}: Adds an item quota to the inventory.")
    print("- Type 'exit' to quit.")
    -- Main loop to handle terminal input
    while true do
        -- Prompt the user for input
        ::start::
        write("> ")
        local input = read()

        if input == "debug" then
            debugVar = not debugVar
            utils.setDebug(debugVar)
            print("Debug mode:", debugVar and "enabled" or "disabled")
            goto start
        end

        -- Trim and split the input into command and arguments
        local command, name, amount = input:match("^(%S+)%s*(%S*)%s*(%d*)$")

        -- Convert amount to number if present
        amount = tonumber(amount)

        -- Handle 'exit' command
        if command == "exit" then
            print("Exiting the system. Goodbye!")
            break
        end

        -- Handle AddFluid command
        if command == "AddFluid" and name and amount then
            if inventory.addFluidQuota then
                inventory.addFluidQuota(name, amount)
                print("Added fluid:", name, "with amount:", amount)
            else
                print("Error: AddFluidQuota function not found in the inventory module.")
            end

            -- Handle AddItem command
        elseif command == "AddItem" and name and amount then
            if inventory.addItemQuota then
                inventory.addItemQuota(name, amount)
                print("Added item:", name, "with amount:", amount)
            else
                print("Error: AddItemQuota function not found in the inventory module.")
            end

            -- Handle invalid input
        else
            print("Invalid command or missing arguments.")
            print("Please use the format: AddFluid {name} {amount} or AddItem {name} {amount}.")
        end
    end
end
return {
    runGui = runGui,
    debugPrint = debugPrint
}
