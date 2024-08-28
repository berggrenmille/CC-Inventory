-- basalt_gui.lua
local basalt = require("basalt")
local globals = require("globals")

local function runGui()
    local main = basalt.createFrame()

    local quotaInput = main:addTextField()
        :setPosition(5, 5)
        :setSize(20, 1)
        :setDefaultText("Enter Quota")

    local submitButton = main:addButton()
        :setPosition(5, 7)
        :setSize(10, 1)
        :setText("Submit")
        :onClick(function()
            local quota = quotaInput:getValue()
            -- Update shared quota variable
            globals.quota[quota] = (globals.quota[quota] or 0) + 1
            print("Updated quota:", quota)
        end)

    basalt.autoUpdate()
end

return {
    runGui = runGui
}
