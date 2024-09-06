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
        :setPosition("parent.h", "parent.h")
        :setSize("parent.w - 2", "parent.h * 0.75")
        :setScrollable(true)

    local function updateList()
        list:clear()
        for name, quota in pairs(globals.quota) do
            list:addItem(name .. ": " .. quota.amount)
        end
    end

    local listTimer = main:addTimer()
    listTimer:onCall(updateList)
        :setTime(1, -1)
        :start()

    local inputName = main:addInput("inputName")
        :setPosition(0, "quotas.h + 5")
        :setSize("parent.w * 0.3", "parent.h * 0.05")
    local inputAmount = main:addInput("inputAmount")
        :setPosition("inputName.w + 5", "quotas.h + 5")
        :setSize("parent.w * 0.2", "parent.h * 0.05")
    local isFluid = main:addCheckbox("isFluid")
        :setPosition("inputAmount.x + inputAmount.w + 5", "quotas.h + 5")
        :setSize("parent.w * 0.1", "parent.h * 0.05")
        :setText("Fluid")

    -- Add and remove buttons under input
    local addButton = main:addButton("addButton")
        :setPosition(0, "inputName.y + inputName.h + 5")
        :setSize("parent.w * 0.3", "parent.h * 0.05")
        :setText("Add")
    local removeButton = main:addButton("removeButton")
        :setPosition("addButton.w + 5", "inputName.y + inputName.h + 5")
        :setSize("parent.w * 0.3", "parent.h * 0.05")
        :setText("Remove")

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
    addButton:onClicked(addClicked)

    local function removeClicked()
        local name = inputName:getValue()
        if not name then
            basalt.debug("Invalid input")
            return
        end
        inventory.removeQuota(name)
        updateList()
    end
    removeButton:onClicked(removeClicked)

    basalt.autoUpdate()
end
return {
    runGui = runGui,
    debugPrint = debugPrint
}
