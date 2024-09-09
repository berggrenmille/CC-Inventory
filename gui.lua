-- basalt_gui.lua
local basalt = require("basalt")
local globals = require("globals")
local inventory = require("inventory")
local utils = require("utils")
local debugVar = false

local function debugPrint(...)
    if debugVar then
        basalt.debug(...)
    end
end

local function runGui()
    local main = basalt.createFrame() -- The main frame/most important frame in your project
    local list = main
        :addList("quotas")
        :setPosition(2, 2)
        :setSize("parent.w - 2", "parent.h * 0.5")
        :setScrollable(true)

    local updateList = basalt.schedule(function()
        list:clear()
        for name, quota in pairs(globals.quota) do
            list:addItem(name .. ": " .. quota.amount, colors.black, colors.white, quota)
        end
    end)

    updateList()
    -- Descriptive Labels
    main:addLabel()
        :setPosition(2, "quotas.h + 3")
        :setText("Item Name:")

    local inputName = main:addInput("inputName")
        :setPosition(2, "quotas.h + 4")
        :setSize("parent.w * 0.4", 1)

    main:addLabel()
        :setPosition("inputName.w + inputName.x + 1", "inputName.y - 1")
        :setText("Amount:")

    local inputAmount = main:addInput("inputAmount")
        :setPosition("inputName.w + inputName.x + 1", "inputName.y")
        :setSize("parent.w * 0.2", 1)

    main:addLabel()
        :setPosition("inputAmount.w + inputAmount.x + 1", "inputAmount.y - 1")
        :setText("Is Fluid:")

    local isFluid = main:addCheckbox("isFluid")
        :setPosition("inputAmount.w + inputAmount.x + 1", "inputAmount.y")
        :setBackground(colors.black)
        :setForeground(colors.white)

    -- Add and Remove Buttons centered at the bottom
    local buttonWidth = (main:getSize() - 6) * 0.3 -- 30% of the screen width
    local buttonHeight = 3
    local spacing = 2
    local totalWidth = buttonWidth * 2 + spacing

    local addButton = main:addButton("addButton")
        :setPosition("(parent.w - " .. totalWidth .. ") / 2", "parent.h - 3")
        :setSize(buttonWidth, buttonHeight)
        :setText("Add")
        :setBackground(colors.green)

    local removeButton = main:addButton("removeButton")
        :setPosition("(parent.w + " .. spacing .. ") / 2", "parent.h - 3")
        :setSize(buttonWidth, buttonHeight)
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
            inventory.addQuota(name, amount, true)
        else
            inventory.addQuota(name, amount, false)
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

    list:onSelect(function(self, event, item)
        inputName:setValue(item.args.name)
        inputAmount:setValue(item.args.amount)
        isFluid:setValue(item.args.isFluid)
    end)

    basalt.autoUpdate()
end

return {
    runGui = runGui,
    debugPrint = debugPrint
}
