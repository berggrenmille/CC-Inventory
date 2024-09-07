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
    local list = main
        :addList("quotas")
        :setPosition("2", "2")
        :setSize("parent.w - 2", "parent.h * 0.5")
        :setScrollable(true)

    local function updateList()
        list:clear()
        for name, quota in pairs(globals.quota) do
            list:addItem(name .. ": " .. quota.amount, colors.black, colors.white)
        end
    end

    local listTimer = main:addTimer()
    listTimer:onCall(updateList)
        :setTime(1, -1)
        :start()

    local inputName = main:addInput("inputName")
        :setPosition("2", "quotas.h + 1")
        :setSize("parent.w * 0.4", 1)
    local inputAmount = main:addInput("inputAmount")
        :setPosition("inputName.w + inputName.x + 1", "inputName.y")
        :setSize("parent.w * 0.2", 1)
    local isFluid = main:addCheckbox("isFluid")
        :setPosition("inputAmount.w + inputAmount.x + 1", "inputAmount.y")
    -- Add and remove buttons under input
    local addButton = main:addButton("addButton")
        :setPosition(2, "inputName.y + inputName.h + 2")
        :setSize("parent.w * 0.3", 2)
        :setText("Add")
        :setBackground(colors.green)
    local removeButton = main:addButton("removeButton")
        :setPosition("addButton.x + addButton.w + 2", "inputName.y + inputName.h + 2")
        :setSize("parent.w * 0.3", 2)
        :setText("Remove")
        :setBackground(colors.red)

    local function addClicked()
        local name = inputName:getValue()
        local amount = tonumber(inputAmount:getValue())
        if not name or not amount then
            basalt.debug("Invalid input")
            return
        end
        if isFluid:getValue() then
            inventory.addFluidQuota(name, amount)
        else
            inventory.addItemQuota(name, amount)
        end
        updateList()
    end
    addButton:onClick(addClicked)

    local function removeClicked()
        local name = inputName:getValue()
        if not name then
            basalt.debug("Invalid input")
            return
        end
        inventory.removeQuota(name)
        updateList()
    end
    removeButton:onClick(removeClicked)

    basalt.autoUpdate()
end
return {
    runGui = runGui,
    debugPrint = debugPrint
}
